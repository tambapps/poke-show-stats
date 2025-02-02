import 'dart:developer' as developer;

import '../../../data/models/teamlytic.dart';
import '../../../data/services/save_service.dart';
import '../core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import '../../data/models/replay.dart';
import '../../data/services/pokemon_resource_service.dart';

class TeamlyticsViewModel extends ChangeNotifier {

  TeamlyticsViewModel({required this.pokemonResourceService, required this.saveService});

  // storing it here even if it used only in the replayEntriesComponent because we don't want
  // to erase/refresh the controller each time the replayEntriesScreen state updates
  final TextEditingController addReplayURIController = TextEditingController();

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  Teamlytic _teamlytic = Teamlytic(saveName: '', sdNames: [], replays: [], pokepaste: null);

  List<Replay> get replays => _teamlytic.replays;
  List<Replay> _filteredReplays = [];
  List<Replay> get filteredReplays => _filteredReplays;
  List<String> get sdNames => _teamlytic.sdNames;
  Pokepaste? get pokepaste => _teamlytic.pokepaste;
  set pokepaste(Pokepaste? value) {
    _teamlytic.pokepaste = value;
    notifyListeners();
    storeSave();
  }

  bool _disposed = false;

  ReplayPredicate? _replayPredicate;
  ReplayPredicate? get replayPredicate => _replayPredicate;
  set replayPredicate(value) {
    _replayPredicate = value;
    if (value != null) {
      developer.log("Applying filters...");
      _filteredReplays = replays.where(value).toList();
    } else {
      _filteredReplays = replays.toList();
    }
    notifyListeners();
  }

  void addReplay(Uri uri, SdReplayData replayData) {
    final PlayerData opposingPlayer = _computeOpposingPlayer(replayData);
    GameOutput output = _computeGameOutput(replayData);
    Replay replay = Replay(uri: uri, data: replayData, opposingPlayer: opposingPlayer, gameOutput: output);
    replay.trySetElo(replays);
    _teamlytic.replays = [...replays, replay];
    if (_replayPredicate == null || _replayPredicate!(replay)) {
      _filteredReplays = [..._filteredReplays, replay];
    }
    notifyListeners();
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
    _teamlytic.replays = [...replays]..remove(replay);
    _filteredReplays = [..._filteredReplays]..remove(replay);
    notifyListeners();
    storeSave();
  }

  // async to avoid freezing the UI
  void addSdName(String sdName) {
    if (!sdNames.contains(sdName)) {
      _teamlytic.sdNames = [...sdNames, sdName];
      _recomputeReplayOutputs();
      notifyListeners();
      storeSave();
    }
  }

  // async to avoid freezing the UI
  void removeSdName(String sdName) async {
    _teamlytic.sdNames = [...sdNames]..remove(sdName);
    _recomputeReplayOutputs();
    _notifyListenersSafely();
    storeSave();
  }

  void _recomputeReplayOutputs() {
    List<Replay> updatedReplays = replays.map((replay) {
      return Replay(uri: replay.uri, data: replay.data, gameOutput: _computeGameOutput(replay.data), opposingPlayer: _computeOpposingPlayer(replay.data));
    }).toList();
    _teamlytic.replays = updatedReplays;
    if (replayPredicate != null) {
      _filteredReplays = replays.where(replayPredicate!).toList();
    }
  }

  void storeSave() async => await saveService.storeSave(_teamlytic);

  void loadSave(String saveName) async {
    _teamlytic = await saveService.loadSave(saveName);
    _filteredReplays = _teamlytic.replays.toList();
    _notifyListenersSafely();
  }

  void _notifyListenersSafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    addReplayURIController.dispose();
    super.dispose();
    _disposed = true;
  }
}
