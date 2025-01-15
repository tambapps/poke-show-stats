import 'dart:collection';

import 'package:app2/data/models/teamlytic.dart';
import 'package:app2/data/services/save_service.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../data/models/replay.dart';
import '../../data/services/pokeapi.dart';
import '../../data/services/pokemon_image_service.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({required this.pokemonImageService, required this.saveService, required this.pokeApi});

  final PokemonImageService pokemonImageService;
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
    _save();
  }

  Map<String, Move> _pokemonMoves = {};
  Map<String, Move> get pokemonMoves => _pokemonMoves;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    // don't need to notifyListeners() because the DefaultTabController handles its own state
    //  I am just listening to the changes of it
    _selectedIndex = index;
  }

  void addReplay(Replay replay) {
    _teamlytic.replays = [...replays, replay];
    notifyListeners();
    _save();
  }

  void removeReplay(Replay replay) {
    _teamlytic.replays = [...replays]..remove(replay);
    notifyListeners();
    _save();
  }

  void addSdName(String sdName) {
    if (!sdNames.contains(sdName)) {
      _teamlytic.sdNames = [...sdNames, sdName];
      notifyListeners();
      _save();
    }
  }

  void removeSdName(String sdName) {
    _teamlytic.sdNames = [...sdNames]..remove(sdName);
    notifyListeners();
    _save();
  }

  void _save() async => await saveService.storeSave(_teamlytic);

  void loadSave() async {
    _teamlytic = await saveService.loadSave(saveName);
    Pokepaste? pokepaste = _teamlytic.pokepaste;
    if (pokepaste != null) {
      _loadPokepasteMoves(pokepaste);
    }
    notifyListeners();
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
          notifyListeners();
        }
      } catch(_) {
        // do nothing
      }
    }
    _pokemonMoves = pokemonMoves;
    notifyListeners();
  }
}
