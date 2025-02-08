import 'dart:developer' as developer;

import 'package:poke_showstats/ui/core/utils.dart';

import '../../../../data/models/teamlytic.dart';
import '../../../../data/services/save_service.dart';
import '../../core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_resource_service.dart';

class TeamlyticsViewModel {

  TeamlyticsViewModel({required this.saveName, required this.pokemonResourceService, required this.saveService}) {
    replaysNotifier.addListener(() {
      filteredReplaysNotifier.value = replayPredicate != null ? replays.where(replayPredicate!).toList() : replays.toList();
    });
  }

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  final String saveName;
  final ValueNotifier<List<String>> sdNamesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Replay>> replaysNotifier = ValueNotifier([]);
  final ValueNotifier<List<Replay>> filteredReplaysNotifier = ValueNotifier([]);
  final ValueNotifier<Pokepaste?> pokepasteNotifier = ValueNotifier(null);
  late ChangeNotifier teamlyticChangeNotifier = CompositeChangeNotifier([sdNamesNotifier, replaysNotifier, filteredReplaysNotifier, pokepasteNotifier]);

  List<Replay> get replays => replaysNotifier.value;
  List<Replay> get filteredReplays => filteredReplaysNotifier.value;
  List<String> get sdNames => sdNamesNotifier.value;
  Pokepaste? get pokepaste => pokepasteNotifier.value;
  set pokepaste(Pokepaste? value) {
    pokepasteNotifier.value = value;
    storeSave();
  }

  ReplayPredicate? _replayPredicate;
  ReplayPredicate? get replayPredicate => _replayPredicate;
  set replayPredicate(value) {
    _replayPredicate = value;
    if (value != null) {
      developer.log("Applying filters...");
      filteredReplaysNotifier.value = replays.where(value).toList();
    } else {
      filteredReplaysNotifier.value = replays.toList();
    }
  }

  void addReplay(Uri uri, SdReplayData replayData) {
    final PlayerData opposingPlayer = _computeOpposingPlayer(replayData);
    GameOutput output = _computeGameOutput(replayData);
    Replay replay = Replay(uri: uri, data: replayData, opposingPlayer: opposingPlayer, gameOutput: output);
    replay.trySetElo(replays);
    replaysNotifier.value = [...replays, replay];
    // reversed because in case of 3 games, G2 must have its elo in order for G1 to find it
    for (Replay replay in replays.reversed) {
      if (replay.data.player1.beforeElo == null && replay.data.player1.afterElo == null
          && replay.data.nextBattle != null) {
        // we're in an intermediate battle (G1 or G2 when it is not the last game) and we need to fetch elo from final battle
        replay.trySetElo(replays);
      }
    }
    storeSave();
  }

  GameOutput _computeGameOutput(SdReplayData replayData) {
    if (sdNames.isEmpty) {
      return GameOutput.UNKNOWN;
    } else if (sdNames.contains(replayData.winnerPlayer.name)) {
      return GameOutput.WIN;
    } else if (sdNames.contains(replayData.player1.name) || sdNames.contains(replayData.player2.name)) {
      return GameOutput.LOSS;
    }
    // the game doesn't reference the player
    return GameOutput.UNKNOWN;
  }

  PlayerData _computeOpposingPlayer(SdReplayData replayData) {
    if (sdNames.isEmpty) {
      return replayData.player1;
    }
    return sdNames.contains(replayData.player2.name) ? replayData.player1 : replayData.player2;
  }

  void removeReplay(Replay replay) {
    replaysNotifier.value = [...replays]..remove(replay);
    storeSave();
  }

  // async to avoid freezing the UI
  void addSdName(String sdName) {
    if (!sdNames.contains(sdName)) {
      sdNamesNotifier.value = [...sdNames, sdName];
      _recomputeReplayOutputs();
      storeSave();
    }
  }

  // async to avoid freezing the UI
  void removeSdName(String sdName) async {
    sdNamesNotifier.value = [...sdNames]..remove(sdName);
    _recomputeReplayOutputs();
    storeSave();
  }

  void _recomputeReplayOutputs() {
    List<Replay> updatedReplays = replays.map((replay) {
      return Replay(uri: replay.uri, data: replay.data, gameOutput: _computeGameOutput(replay.data), opposingPlayer: _computeOpposingPlayer(replay.data));
    }).toList();
    replaysNotifier.value = updatedReplays;
  }

  void dispose() {
    // will remove listener of replaysNotifier
    teamlyticChangeNotifier.dispose();
  }

  void storeSave() async => await saveService.storeSave(Teamlytic(saveName: saveName, sdNames: sdNames, replays: replays, pokepaste: pokepaste));

  void loadSave() async {
    Teamlytic teamlytic = await saveService.loadSave(saveName);
    sdNamesNotifier.value = teamlytic.sdNames;
    pokepasteNotifier.value = teamlytic.pokepaste;
    replaysNotifier.value = teamlytic.replays;
  }
}

abstract class TeamlyticsTabViewModel {
  final TeamlyticsViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  int get replaysCount => homeViewModel.filteredReplays.length;
  PokemonResourceService get pokemonResourceService => homeViewModel.pokemonResourceService;
  List<Replay> get filteredReplays => homeViewModel.filteredReplays;

  TeamlyticsTabViewModel({required this.homeViewModel}) {
    homeViewModel.teamlyticChangeNotifier.addListener(onTeamlyticsChanged);
  }

  void onTeamlyticsChanged();
}