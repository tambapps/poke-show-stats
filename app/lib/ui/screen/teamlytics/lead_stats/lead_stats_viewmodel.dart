import 'package:pokemon_core/pokemon_core.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../../data/models/replay.dart';
import '../teamlytics_viewmodel.dart';

class LeadStatsViewModel extends TeamlyticsTabViewModel {

  LeadStatsViewModel({required super.homeViewModel});

}

class LeadStats {

  final Map<Duo<String>, WinStats> duoStatsMap;
  final Map<String, WinStats> pokemonStats;

  LeadStats({this.duoStatsMap = const {}, this.pokemonStats = const {}});

  static LeadStats fromReplays(List<Replay> replays) {
    Map<Duo<String>, WinStats> duoStatsMap = {};
    Map<String, WinStats> pokemonStatsMap = {};
    for (Replay replay in replays) {
      _fill(duoStatsMap, replay);
      _fillPokemonStats(pokemonStatsMap, replay);
    }
    return LeadStats(duoStatsMap: duoStatsMap, pokemonStats: pokemonStatsMap);
  }

  static void _fillPokemonStats(Map<String, WinStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    PlayerData player = replay.otherPlayer;
    for (int i = 0; i < 2 && i < player.selection.length; i++) {
      String pokemon = player.selection[i];
      WinStats stats = map.putIfAbsent(pokemon, () => WinStats());
      if (replay.gameOutput == GameOutput.WIN) {
        stats.winCount++;
      }
      stats.total++;
    }
  }

  static void _fill(Map<Duo<String>, WinStats> map, Replay replay) {
    if (replay.gameOutput == GameOutput.UNKNOWN) return;
    Duo<String> duo = Duo(Pokemon.normalize(replay.otherPlayer.selection[0]), Pokemon.normalize(replay.otherPlayer.selection[1]));
    WinStats stats = map.putIfAbsent(duo, () => WinStats());
    if (replay.gameOutput == GameOutput.WIN) {
      stats.winCount++;
    }
    stats.total++;
  }
}

class WinStats {
  int winCount = 0;
  int total = 0;

  double get winRate => winCount / total;

  @override
  String toString() {
    return 'WinStats{winCount: $winCount, total: $total}';
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