import 'dart:collection';

import 'package:app2/data/models/teamlytic.dart';
import 'package:app2/data/services/save_service.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import '../../data/models/replay.dart';
import '../../data/services/pokeapi.dart';
import '../../data/services/pokemon_resource_service.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({required this.pokemonResourceService, required this.saveService, required this.pokeApi});

  // storing it here even if it used only in the replayEntriesComponent because we don't want
  // to erase/refresh the controller each time the replayEntriesScreen state updates
  final TextEditingController addReplayURIController = TextEditingController();

  PokemonResourceService pokemonResourceService;
  final SaveService saveService;
  final PokeApi pokeApi;

  Teamlytic _teamlytic = Teamlytic(saveName: '', sdNames: [], replays: [], pokepaste: null);
  // TODO hack for now as we cannot select multiple saves
  final String saveName = "default";

  List<Replay> get replays => _teamlytic.replays;
  List<String> get sdNames => _teamlytic.sdNames;
  Pokepaste? get pokepaste => _teamlytic.pokepaste;
  set pokepaste(Pokepaste? value) {
    _teamlytic.pokepaste = value;
    if (value != null) {
      _loadPokepasteMoves(value);
    }
    notifyListeners();
    storeSave();
  }

  Map<String, Move> _pokemonMoves = {};
  Map<String, Move> get pokemonMoves => _pokemonMoves;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  bool _disposed = false;

  void onTabSelected(int index) {
    // don't need to notifyListeners() because the DefaultTabController handles its own state
    //  I am just listening to the changes of it
    _selectedIndex = index;
  }

  void addReplay(Uri uri, SdReplayData replayData) {
    final PlayerData opposingPlayer = _computeOpposingPlayer(replayData);
    GameOutput output = _computeGameOutput(replayData);
    Replay replay = Replay(uri: uri, data: replayData, opposingPlayer: opposingPlayer, gameOutput: output);
    _teamlytic.replays = [...replays, replay];
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
  }

  void storeSave() async => await saveService.storeSave(_teamlytic);

  void loadSave() async {
    _teamlytic = await saveService.loadSave(saveName);
    Pokepaste? pokepaste = _teamlytic.pokepaste;
    if (pokepaste != null) {
      _loadPokepasteMoves(pokepaste);
    }
    _notifyListenersSafely();
  }

  void _loadPokepasteMoves(Pokepaste pokepaste) async {
    // collect all moves to load
    Set<String> moves = HashSet();
    for (Pokemon pokemon in pokepaste.pokemons) {
      moves.addAll(pokemon.moves);
    }
    Map<String, Move> pokemonMoves = {};
    for (String moveName in moves) {
      try {
        Move? move = await pokeApi.getMove(moveName);
        if (move != null) {
          pokemonMoves[moveName] = move;
        }
      } catch(_) {
        // do nothing
      }
    }
    _pokemonMoves = pokemonMoves;
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
