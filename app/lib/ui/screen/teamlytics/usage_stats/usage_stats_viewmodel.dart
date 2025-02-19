import '../../../../data/models/replay.dart';
import '../../../../data/services/pokemon_resource_service.dart';

class UsageStatsViewModel {

  final PokemonResourceService pokemonResourceService;

  UsageStatsViewModel({required this.pokemonResourceService});

}

class PokemonUsageStats {
  final Map<String, UsageStats> usages;

  PokemonUsageStats(this.usages);

  static PokemonUsageStats fromReplays(List<Replay> replays) {
    Map<String, UsageStats> pokemonUsageStatsMap = {};
    for (Replay replay in replays) {
      _fill(pokemonUsageStatsMap, replay);
    }
    return PokemonUsageStats(pokemonUsageStatsMap);
  }

  static void _fill(Map<String, UsageStats> pokemonUsageStatsMap, Replay replay) {
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