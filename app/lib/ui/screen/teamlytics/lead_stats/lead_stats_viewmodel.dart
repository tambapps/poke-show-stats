import 'package:flutter/material.dart';
import 'package:pokemon_core/pokemon_core.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../../data/models/replay.dart';
import '../../../../data/services/pokemon_resource_service.dart';
import '../teamlytics_viewmodel.dart';

class LeadStatsViewModel {
  final TeamlyticsViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;


  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final PokemonResourceService pokemonResourceService;

  ValueNotifier<Stats> stats = ValueNotifier(Stats());

  LeadStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
  }) {
    _loadUsages();
  }

  void _loadUsages() async {
    isLoading.value = true;
    List<Replay> replays = homeViewModel.filteredReplays;
    Map<Duo<String>, LeadStats> duoStatsMap = {};
    Map<String, LeadStats> pokemonStatsMap = {};
    for (Replay replay in replays) {
      _fill(duoStatsMap, replay);
      _fillPokemonStats(pokemonStatsMap, replay);
    }
    stats.value = Stats(duoStatsMap: duoStatsMap, pokemonStats: pokemonStatsMap);
    isLoading.value = false;
  }

  void _fillPokemonStats(Map<String, LeadStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    PlayerData player = replay.otherPlayer;
    for (int i = 0; i < 2 && i < player.selection.length; i++) {
      String pokemon = player.selection[i];
      LeadStats stats = map.putIfAbsent(pokemon, () => LeadStats());
      if (replay.gameOutput == GameOutput.WIN) {
        stats.winCount++;
      }
      stats.total++;
    }
  }

  void _fill(Map<Duo<String>, LeadStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    Duo<String> duo = Duo(Pokemon.normalize(replay.otherPlayer.selection[0]), Pokemon.normalize(replay.otherPlayer.selection[1]));
    LeadStats stats = map.putIfAbsent(duo, () => LeadStats());
    if (replay.gameOutput == GameOutput.WIN) {
      stats.winCount++;
    }
    stats.total++;
  }
}

class Stats {

  final Map<Duo<String>, LeadStats> duoStatsMap;
  final Map<String, LeadStats> pokemonStats;

  Stats({this.duoStatsMap = const {}, this.pokemonStats = const {}});

}

class LeadStats {
  int winCount = 0;
  int total = 0;

  double get winRate => winCount / total;

  @override
  String toString() {
    return 'LeadStats{winCount: $winCount, total: $total}';
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