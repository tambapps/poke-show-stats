import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../../data/models/replay.dart';
import '../../../../data/services/pokemon_resource_service.dart';
import '../teamlytics_viewmodel.dart';

class UsageStatsViewModel {
  final TeamlyticsViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  int get replaysCount => homeViewModel.filteredReplays.length;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<Map<String, UsageStats>> pokemonUsageStats = ValueNotifier({});

  final PokemonResourceService pokemonResourceService;


  UsageStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
  }) {
    _loadUsages();
  }

  void _loadUsages() {
    isLoading.value = true;
    Map<String, UsageStats> pokemonUsageStatsMap = {};
    List<Replay> replays = homeViewModel.filteredReplays;
    for (Replay replay in replays) {
      _fill(pokemonUsageStatsMap, replay);
    }
    pokemonUsageStats.value = pokemonUsageStatsMap;
    isLoading.value = false;
  }

  void _fill(Map<String, UsageStats> pokemonUsageStatsMap, Replay replay) {
    for (String pokemon in replay.otherPlayer.selection) {
      UsageStats stats = pokemonUsageStatsMap.putIfAbsent(pokemon, () => UsageStats());
      bool terastilized = replay.otherPlayer.terastallization?.pokemon == pokemon;
      bool won = replay.gameOutput == GameOutput.WIN;
      if (won) {
        stats.winCount++;
      }
      if (won && terastilized) {
        stats.teraAndWinCount++;
      }
      if (terastilized) {
        stats.teraCount++;
      }
      stats.total++;
    }
  }
}


class UsageStats {
  int winCount = 0;
  int teraAndWinCount = 0;
  int teraCount = 0;
  int total = 0;
}