import 'package:app2/data/models/replay.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../home_viewmodel.dart';

class MoveUsageViewModel extends ChangeNotifier {

  MoveUsageViewModel({
    required this.homeViewModel,
    required this.pokemonResourceService,
  }) {
    loadStats();
  }

  final HomeViewModel homeViewModel;
  final PokemonResourceService pokemonResourceService;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  Map<String, Map<String, int>> _pokemonMoveUsages = {};
  Map<String, Map<String, int>> get pokemonMoveUsages => _pokemonMoveUsages;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void loadStats() async {
    _isLoading = true;
    notifyListeners();
    List<Replay> replays = homeViewModel.filteredReplays;
    Map<String, Map<String, int>> map = {};
    for (Replay replay in replays) {
      _merge(map, replay.otherPlayer.moveUsages);
    }
    _pokemonMoveUsages = map;
    _isLoading = false;
    notifyListeners();
  }

  void _merge(Map<String, Map<String, int>> resultMap, Map<String, Map<String, int>> map) {
    map.forEach((String pokemonName, Map<String, int> pokemonMoves) {
      resultMap.update(pokemonName, (resultPokemonMoves) {
        pokemonMoves.forEach((moveName, count) =>
            resultPokemonMoves.update(moveName, (resultMoveCount) => resultMoveCount + count,
                ifAbsent: () => count));
        return resultPokemonMoves;
      }, ifAbsent: () => {...pokemonMoves});
    });
  }
}
