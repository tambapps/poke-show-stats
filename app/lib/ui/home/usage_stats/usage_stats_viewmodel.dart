import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

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

  Map<Duo<String>, LeadAndWinStats> _duoStatsMap = {};
  Map<Duo<String>, LeadAndWinStats> get duoStatsMap => _duoStatsMap;

  Map<String, LeadAndWinStats> _pokemonStats = {};
  Map<String, LeadAndWinStats> get pokemonStats => _pokemonStats;

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
    Map<Duo<String>, LeadAndWinStats> duoStatsMap = {};
    Map<String, LeadAndWinStats> pokemonStatsMap = {};
    for (Replay replay in replays) {
      _fill(duoStatsMap, replay);
      _fillPokemonStats(pokemonStatsMap, replay);
    }
    _duoStatsMap = duoStatsMap;
    _pokemonStats = pokemonStatsMap;
    _isLoading = false;
    notifyListeners();
  }

  void _fillPokemonStats(Map<String, LeadAndWinStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    PlayerData player = replay.otherPlayer;
    for (int i= 0; i < 2 && i < player.selection.length; i++) {
      String pokemon = player.selection[i];
      LeadAndWinStats stats = map.putIfAbsent(pokemon, () => LeadAndWinStats());
      if (replay.gameOutput == GameOutput.WIN) {
        stats.winCount++;
      }
      stats.total++;
    }
  }

  void _fill(Map<Duo<String>, LeadAndWinStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    Duo<String> duo = Duo(replay.otherPlayer.selection[0], replay.otherPlayer.selection[1]);
    LeadAndWinStats stats = map.putIfAbsent(duo, () => LeadAndWinStats());
    if (replay.gameOutput == GameOutput.WIN) {
      stats.winCount++;
    }
    stats.total++;
  }
}


class LeadAndWinStats {
  int winCount = 0;
  int total = 0;

  double get winRate => winCount / total;

  @override
  String toString() {
    return 'PairStats{winCount: $winCount, total: $total}';
  }
}

class Duo<T> {
  final T first;
  final T second;

  Duo(this.first, this.second);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Duo && runtimeType == other.runtimeType &&
              (first == other.first || first == other.second) &&
              (second == other.second || second == other.first);

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  @override
  String toString() {
    return '($first, $second)';
  }

  List<T> toList() => [first, second];
}