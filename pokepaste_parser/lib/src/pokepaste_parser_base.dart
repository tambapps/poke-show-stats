import 'dart:collection';

import 'package:pokemon_core/pokemon_core.dart';

import 'model.dart';

class PokepasteParser {
  Pokepaste parse(String input) {
    List<Pokemon> pokemons = [];
    // need to trim the whole input because it may end with empty line(s)
    // need to trim each element because the lines have \r at the end (berk, Windows)
    Queue<String> lines = Queue.of(input.trim().split('\n').map((line) => line.trim()));
    while (lines.isNotEmpty) {
      // need to specify moves to have a mutable list
      Pokemon pokemon = Pokemon(moves: []);
      String line = lines.removeFirst();
      List<String> firstLineFields = line.split("@");
      if (firstLineFields.length != 2) {
        throw PokepasteParsingException("Invalid pokepaste");
      }
      String firstPart = firstLineFields.first.trim();
      if (firstPart.contains('(')) {
        pokemon.gender = firstPart.substring(firstPart.indexOf('(') + 1, firstPart.indexOf(')'));
        firstPart = firstPart.substring(0, firstPart.indexOf('(')).trim();
      }
      pokemon.name = firstPart.replaceAll(' ', '-');
      pokemon.item = firstLineFields.last.trim();
      while (lines.isNotEmpty && (line = lines.removeFirst()).isNotEmpty) {
        if (line.startsWith('Ability:')) {
          pokemon.ability = _extractLeft(line);
        } else if (line.startsWith('Tera Type:')) {
          pokemon.teraType = _extractLeft(line);
        } else if (line.startsWith('Level:')) {
          pokemon.level = int.parse(_extractLeft(line));
        } else if (line.startsWith('EVs:')) {
          pokemon.evs = _parseStats(_extractLeft(line), 0);
        } else if (line.startsWith('IVs:')) {
          pokemon.ivs = _parseStats(_extractLeft(line), 31);
        } else if (line.endsWith('Nature')) {
          pokemon.nature = line.substring(0, line.indexOf(' '));
        } else if (line.startsWith('- ')) {
          pokemon.moves.add(line.substring(2));
        }
      }
      pokemons.add(pokemon);
    }
    if (pokemons.isEmpty) {
      throw PokepasteParsingException("No pokemon was found");
    }
    return Pokepaste(pokemons);
  }

  Stats _parseStats(String line, int defaultValue) {
    List<String> statsParts = line.split(' / ');
    Stats stats = Stats.withDefault(defaultValue);
    for (String part in statsParts) {
      List<String> statParts = part.split(' ');
      int stat = int.parse(statParts.first);
      switch (statParts.last) {
        case 'Atk':
          stats.attack = stat;
          break;
        case 'Def':
          stats.defense = stat;
          break;
        case 'SpA':
          stats.specialAttack = stat;
          break;
        case 'SpD':
          stats.specialDefense = stat;
          break;
        case 'HP':
          stats.hp = stat;
          break;
        case 'Spe':
          stats.speed = stat;
          break;
      }
    }
    return stats;
  }

  String _extractLeft(String line) => line.substring(line.indexOf(': ') + 2).trim();
}


class PokepasteParsingException implements Exception {
  final String message;

  PokepasteParsingException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}