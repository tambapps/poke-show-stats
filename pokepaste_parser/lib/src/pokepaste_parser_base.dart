import 'model.dart';

class PokepasteParser {
  Pokepaste parse(String input) {
    List<Pokemon> pokemons = [];
    List<String> lines = input.split('\n');
    int i = 0;
    while (i < lines.length) {
      // TODO
    }
    return Pokepaste(pokemons);
  }
}
