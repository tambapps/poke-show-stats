import 'dart:collection';

import 'package:pokemon_core/pokemon_core.dart';

import 'model.dart';

class PokepasteParser {
  static final RegExp _pokemonHeaderRegex = RegExp(r'(\S+)(?: \(([^()]+)\))?(?: \(([FM])\))?(?: @ (\S+))?');

  Pokepaste parse(String input) {
    List<Pokemon> pokemons = [];
    // need to trim the whole input because it may end with empty line(s)
    // need to trim each element because the lines have \r at the end (berk, Windows)
    Queue<String> lines = Queue.of(input.trim().split('\n').map((line) => line.trim()));
    while (lines.isNotEmpty) {
      // need to specify moves to have a mutable list
      Pokemon pokemon = Pokemon(moves: []);
      String line = lines.removeFirst();
      _parsePokemonHeaderLine(line, pokemon);
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

  void _parsePokemonHeaderLine(String line, Pokemon pokemon) {
    // first handle object and then discard it from
    if (line.contains("@")) {
      List<String> firstLineFields = line.split("@");
      pokemon.item = firstLineFields.last.trim();
      line = firstLineFields.first.trim();
    }

    int nbParenthesis = _countOccurrences(line, '(');
    switch (nbParenthesis) {
      case 0:
        // no surname and no specific gender
        pokemon.name = line.replaceAll(' ', '-');
        break;
      case 1:
        // surname or gender
        String parenthesisContent = line.substring(line.indexOf('(') + 1, line.indexOf(')')).replaceAll(' ', '-');
        if (parenthesisContent == 'M' || parenthesisContent  == 'F') {
          pokemon.name = line.substring(0, line.indexOf('(')).trim().replaceAll(' ', '-');
          pokemon.gender = parenthesisContent;
        } else {
          pokemon.name = parenthesisContent;
        }
        break;
      case 2:
      // both surname and gender
        pokemon.name = line.substring(line.indexOf('(') + 1, line.indexOf(')')).replaceAll(' ', '-');
        pokemon.gender = line.substring(line.lastIndexOf('(') + 1, line.lastIndexOf(')'));
        break;
      default:
        throw PokepasteParsingException("Invalid pokepaste");
    }
  }

  int _countOccurrences(String input, String char) {
    int count = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == char) count++;
    }
    return count;
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