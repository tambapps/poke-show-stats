import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_resource_service.dart';
import '../../core/widgets/replay_filters.dart';
import '../home_viewmodel.dart';

class UsageStatsViewModel extends ChangeNotifier {
  final HomeViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  int _replaysCount = 0;
  int get replaysCount => _replaysCount;
  bool get hasReplays => homeViewModel.replays.isNotEmpty;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final ReplayFiltersViewModel filtersViewModel;
  final PokemonResourceService pokemonResourceService;

  Map<Pair<String>, PairStats> _pairStatsMap = {};
  Map<Pair<String>, PairStats> get pairStatsMap => _pairStatsMap;

  UsageStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
  }): filtersViewModel = ReplayFiltersViewModel(pokemonResourceService: pokemonResourceService) {
    loadUsages();
  }

  void loadUsages({ReplayPredicate? replayPredicate}) async {
    _isLoading = true;
    notifyListeners();
    developer.log("Applying filters...");
    List<Replay> replays = replayPredicate != null ? homeViewModel.replays
        .where((replay) => replayPredicate(replay))
        .toList()
        : homeViewModel.replays;
    _replaysCount = replays.length;
    Map<Pair<String>, PairStats> map = {};
    for (Replay replay in replays) {
      _fill(map, replay);
    }
    _pairStatsMap = map;
    _isLoading = false;
    notifyListeners();
  }

  void _fill(Map<Pair<String>, PairStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    Pair<String> pair = Pair(replay.otherPlayer.selection[0], replay.otherPlayer.selection[1]);
    PairStats stats = map.putIfAbsent(pair, () => PairStats());
    if (replay.gameOutput == GameOutput.WIN) {
      stats.winCount++;
    }
    stats.total++;
  }
}


class PairStats {
  int winCount = 0;
  int total = 0;

  double get winRate => winCount / total;

  @override
  String toString() {
    return 'PairStats{winCount: $winCount, total: $total}';
  }
}

class Pair<T> {
  final T first;
  final T second;

  Pair(this.first, this.second);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pair && runtimeType == other.runtimeType &&
              (first == other.first || first == other.second) &&
              (second == other.second || second == other.first);

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  @override
  String toString() {
    return '($first, $second)';
  }
}