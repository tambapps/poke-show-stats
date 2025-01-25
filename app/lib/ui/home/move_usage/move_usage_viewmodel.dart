import 'dart:developer' as developer;

import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../home_viewmodel.dart';

class MoveUsageViewModel extends ChangeNotifier {

  MoveUsageViewModel({
    required this.homeViewModel,
    required this.pokemonResourceService,
  }): filtersViewModel = ReplayFiltersViewModel(pokemonResourceService: pokemonResourceService);

  final HomeViewModel homeViewModel;
  final PokemonResourceService pokemonResourceService;
  final ReplayFiltersViewModel filtersViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  Map<String, Map<String, int>> _pokemonMoveUsages = {};
  Map<String, Map<String, int>> get pokemonMoveUsages => _pokemonMoveUsages;
  int _replaysCount = 0;
  int get replaysCount => _replaysCount;
  bool get hasReplays => homeViewModel.replays.isNotEmpty;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void loadStats({ReplayPredicate? replayPredicate}) async {
    _isLoading = true;
    notifyListeners();
    developer.log("Applying filters...");
    List<Replay> replays = replayPredicate != null ? homeViewModel.replays
        .where((replay) => replayPredicate(replay))
        .toList()
        : homeViewModel.replays;
    _replaysCount = replays.length;
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

  @override
  void dispose() {
    filtersViewModel.dispose();
    super.dispose();
  }
}

class MoveUsageStats {

}