import 'package:pokemon_core/pokemon_core.dart';

import '../../../../data/models/replay.dart';

class MoveUsageViewModel {

  MoveUsageViewModel();

}

class PokemonMoveUsageStats {
  final Map<String, Map<String, int>> usages;

  PokemonMoveUsageStats(this.usages);

  static PokemonMoveUsageStats fromReplays(List<Replay> replays) {
    Map<String, Map<String, int>> map = {};
    for (Replay replay in replays) {
      _merge(map, replay.otherPlayer.moveUsages);
    }
    return PokemonMoveUsageStats(map);
  }

  static void _merge(Map<String, Map<String, int>> resultMap, Map<String, Map<String, int>> map) {
    map.forEach((String pokemonName, Map<String, int> pokemonMoves) {
      resultMap.update(Pokemon.normalizeToBase(pokemonName), (resultPokemonMoves) {
        pokemonMoves.forEach((moveName, count) {
          if (Pokemon.normalize(moveName) != 'struggle') {
            resultPokemonMoves.update(moveName, (resultMoveCount) => resultMoveCount + count,
                ifAbsent: () => count);
          }
        });
        return resultPokemonMoves;
      }, ifAbsent: () => {...pokemonMoves});
    });
  }

}