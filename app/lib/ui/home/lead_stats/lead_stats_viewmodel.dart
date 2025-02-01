import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_resource_service.dart';
import '../home_viewmodel.dart';

class LeadStatsViewModel extends ChangeNotifier {
  final HomeViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final PokemonResourceService pokemonResourceService;

  Map<Duo<String>, LeadStats> _duoStatsMap = {};
  Map<Duo<String>, LeadStats> get duoStatsMap => _duoStatsMap;

  Map<String, LeadStats> _pokemonStats = {};
  Map<String, LeadStats> get pokemonStats => _pokemonStats;

  LeadStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
  }) {
    loadUsages();
  }

  void loadUsages() async {
    _isLoading = true;
    notifyListeners();
    List<Replay> replays = homeViewModel.filteredReplays;
    Map<Duo<String>, LeadStats> duoStatsMap = {};
    Map<String, LeadStats> pokemonStatsMap = {};
    for (Replay replay in replays) {
      _fill(duoStatsMap, replay);
      _fillPokemonStats(pokemonStatsMap, replay);
    }
    _duoStatsMap = duoStatsMap;
    _pokemonStats = pokemonStatsMap;
    _isLoading = false;
    notifyListeners();
  }

  void _fillPokemonStats(Map<String, LeadStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    PlayerData player = replay.otherPlayer;
    for (int i= 0; i < 2 && i < player.selection.length; i++) {
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
    Duo<String> duo = Duo(replay.otherPlayer.selection[0], replay.otherPlayer.selection[1]);
    LeadStats stats = map.putIfAbsent(duo, () => LeadStats());
    if (replay.gameOutput == GameOutput.WIN) {
      stats.winCount++;
    }
    stats.total++;
  }
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