import 'package:pokemon_core/pokemon_core.dart';

import '../../../../data/models/replay.dart';
import 'package:flutter/material.dart';
import '../teamlytics_viewmodel.dart';

class MoveUsageViewModel extends TeamlyticsTabViewModel {

  ValueNotifier<Map<String, Map<String, int>>> pokemonMoveUsages = ValueNotifier({});
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  MoveUsageViewModel({required super.homeViewModel}) {
    _loadStats();
  }

  @override
  void onTeamlyticsChanged() => _loadStats();

  void _loadStats() async {
    isLoading.value = true;
    List<Replay> replays = homeViewModel.filteredReplays;
    Map<String, Map<String, int>> map = {};
    for (Replay replay in replays) {
      _merge(map, replay.otherPlayer.moveUsages);
    }
    pokemonMoveUsages.value = map;
    isLoading.value = false;
  }

  void _merge(Map<String, Map<String, int>> resultMap, Map<String, Map<String, int>> map) {
    map.forEach((String pokemonName, Map<String, int> pokemonMoves) {
      resultMap.update(Pokemon.normalizeToBase(pokemonName), (resultPokemonMoves) {
        pokemonMoves.forEach((moveName, count) =>
            resultPokemonMoves.update(moveName, (resultMoveCount) => resultMoveCount + count,
                ifAbsent: () => count));
        return resultPokemonMoves;
      }, ifAbsent: () => {...pokemonMoves});
    });
  }
}
