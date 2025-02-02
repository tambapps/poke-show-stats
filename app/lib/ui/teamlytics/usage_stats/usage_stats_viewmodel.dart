import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_resource_service.dart';
import '../../core/widgets/replay_filters.dart';
import '../teamlytics_viewmodel.dart';

class UsageStatsViewModel extends ChangeNotifier {
  final TeamlyticsViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  int get replaysCount => homeViewModel.filteredReplays.length;
//  bool get hasReplays => homeViewModel.replays.isNotEmpty;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final PokemonResourceService pokemonResourceService;

  Map<String, UsageStats> _pokemonUsageStats = {};
  Map<String, UsageStats> get pokemonUsageStats => _pokemonUsageStats;

  UsageStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
  }) {
    _loadUsages();
  }


  void _loadUsages() {
    _isLoading = true;
    notifyListeners();
    Map<String, UsageStats> pokemonUsageStatsMap = {};
    List<Replay> replays = homeViewModel.filteredReplays;
    for (Replay replay in replays) {
      _fill(pokemonUsageStatsMap, replay);
    }
    _pokemonUsageStats = pokemonUsageStatsMap;
    _isLoading = false;
    notifyListeners();
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