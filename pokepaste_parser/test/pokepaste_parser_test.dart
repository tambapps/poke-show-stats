import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Replay parser test', () {
    final parser = PokepasteParser();

    setUp(() {
      // Additional setup goes here.
    });

    test('Parse test', () async {
      final url = Uri.parse('https://pokepast.es/c5eeb30641e39b79/raw');
      final response = await http.get(url);
      final text = response.body;

      final pokepaste = parser.parse(text);

      final List<Pokemon> expectedMons = [
        Pokemon(
            name: 'Miraidon',
            ability: 'Hadron Engine',
            item: 'Choice Specs',
            level: 50,
            teraType: 'Fairy',
            evs: Stats(specialAttack: 252, specialDefense: 4, speed: 252),
            nature: 'Modest',
            moves: ['Volt Switch', 'Draco Meteor', 'Electro Drift', 'Dazzling Gleam']
        ),
        Pokemon(
            name: 'Entei',
            ability: 'Inner Focus',
            item: 'Choice Band',
            level: 50,
            teraType: 'Normal',
            evs: Stats(hp: 140, attack: 252, specialDefense: 116),
            nature: 'Adamant',
            moves: ['Sacred Fire', 'Crunch', 'Stomping Tantrum', 'Extreme Speed']
        ),
        Pokemon(
            name: 'Chien-Pao',
            ability: 'Sword of Ruin',
            item: 'Focus Sash',
            level: 50,
            teraType: 'Stellar',
            evs: Stats(attack: 252, speed: 252),
            nature: 'Jolly',
            moves: ['Icicle Crash', 'Sucker Punch', 'Sacred Sword', 'Protect']
        ),
        Pokemon(
            name: 'Iron-Hands',
            ability: 'Quark Drive',
            item: 'Assault Vest',
            level: 50,
            teraType: 'Water',
            evs: Stats(attack: 252, defense: 20, specialDefense: 236),
            ivs: Stats(attack: 31, speed: 0, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            nature: 'Brave',
            moves: ['Drain Punch', 'Low Kick', 'Heavy Slam', 'Fake Out']
        ),
        Pokemon(
            name: 'Whimsicott',
            ability: 'Prankster',
            item: 'Covert Cloak',
            level: 50,
            teraType: 'Dark',
            evs: Stats(specialAttack: 252, speed: 252),
            ivs: Stats(attack: 0, speed: 31, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            nature: 'Modest',
            moves: ['Moonblast', 'Encore', 'Light Screen', 'Tailwind']
        ),
        Pokemon(
            name: 'Ogerpon-Cornerstone',
            ability: 'Sturdy',
            gender: 'F',
            item: 'Cornerstone Mask',
            level: 50,
            teraType: 'Rock',
            evs: Stats(attack: 252, speed: 252),
            nature: 'Adamant',
            moves: ['Ivy Cudgel', 'Horn Leech', 'Spiky Shield', 'Follow Me']
        )
      ];
      for (int i = 0; i < expectedMons.length; i++) {
        expect(pokepaste.pokemons[i], expectedMons[i]);
      }
    });
  });
}
