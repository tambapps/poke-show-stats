import 'dart:developer' as developer;

import 'package:poke_showstats/data/models/matchup.dart';
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

  TeamlyticsViewModel({required Teamlytic teamlytic, required this.pokemonResourceService, required this.saveService}): saveName = teamlytic.saveName {
    sdNamesNotifier.value = teamlytic.sdNames;
    pokepasteNotifier.value = teamlytic.pokepaste;
    replaysNotifier.value = teamlytic.replays;
    matchUpsNotifiers.value = teamlytic.matchUps;
    teamNotesNotifier.value = teamlytic.teamNotes;
    filteredReplaysNotifier.value = replaysNotifier.value.toList();
    replaysNotifier.addListener(() {
      filteredReplaysNotifier.value = replayPredicate != null ? replays.where(replayPredicate!).toList() : replays.toList();
    });
  }

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  final String saveName;
  final ValueNotifier<bool> matchMode = ValueNotifier(false);
  final ValueNotifier<List<String>> sdNamesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Replay>> replaysNotifier = ValueNotifier([]);
  final ValueNotifier<List<Replay>> filteredReplaysNotifier = ValueNotifier([]);
  final ValueNotifier<List<MatchUp>> matchUpsNotifiers = ValueNotifier([]);
  final ValueNotifier<Pokepaste?> pokepasteNotifier = ValueNotifier(null);
  final ValueNotifier<String?> teamNotesNotifier = ValueNotifier(null);
  late ChangeNotifier teamlyticChangeNotifier = CompositeChangeNotifier([sdNamesNotifier, replaysNotifier, filteredReplaysNotifier, pokepasteNotifier, matchUpsNotifiers, teamNotesNotifier]);

  void dispose() {
    matchMode.dispose();
    sdNamesNotifier.dispose();
    replaysNotifier.dispose();
    filteredReplaysNotifier.dispose();
    matchUpsNotifiers.dispose();
    pokepasteNotifier.dispose();
    teamNotesNotifier.dispose();
    teamlyticChangeNotifier.dispose();
  }

  List<Replay> get replays => replaysNotifier.value;
  List<List<Replay>> get filteredMatches {
    List<List<Replay>> matches = [];
    final filteredReplays = this.filteredReplays;
    if (filteredReplays.isEmpty) {
      return matches;
    }
    List<Replay> currentMatch = [filteredReplays.first];
    int i = 1;
    while(i < filteredReplays.length) {
      final currentReplay = filteredReplays[i++];
      if (currentReplay.isNextBattleOf(currentMatch.last)) {
        currentMatch.add(currentReplay);
      } else {
        matches.add(currentMatch);
        currentMatch = [currentReplay];
      }
    }
    if (matches.last != currentMatch) {
      matches.add(currentMatch);
    }
    return matches;
  }

  List<MatchUp> get matchUps => matchUpsNotifiers.value;
  List<Replay> get filteredReplays => filteredReplaysNotifier.value;
  List<String> get sdNames => sdNamesNotifier.value;
  Pokepaste? get pokepaste => pokepasteNotifier.value;
  set pokepaste(Pokepaste? value) {
    pokepasteNotifier.value = value;
    storeSave();
  }

  String? get teamNotes => teamNotesNotifier.value;
  set teamNotes(String? value) {
    teamNotesNotifier.value = value;
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
      if (replay.data.player1.beforeElo == null && replay.data.player1.afterElo == null) {
        // we're in an intermediate battle (G1 or G2 when it is not the last game) and we need to fetch elo from final battle
        replay.trySetElo(replays);
      }
    }
    storeSave();
  }

  void addMatchUp(MatchUp matchUp) {
    matchUpsNotifiers.value = [...matchUps, matchUp];
    storeSave();
  }

  void removeMatchUp(MatchUp matchUp) {
    matchUpsNotifiers.value = [...matchUps]..remove(matchUp);
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


  void storeSave() async => await saveService.storeSave(Teamlytic(saveName: saveName, sdNames: sdNames, replays: replays, matchUps: matchUps, pokepaste: pokepaste, lastUpdatedAt: currentTimeMillis(), teamNotes: teamNotes));


}
