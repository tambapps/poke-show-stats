import 'package:pokemon_core/pokemon_core.dart';
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

      Pokepaste fromString = parser.parse(pokepaste.toString());
      for (int i = 0; i < pokepaste.pokemons.length; i++) {
        expect(fromString.pokemons[i], pokepaste.pokemons[i]);
      }
    });

    test('Parse test with surnames', () async {
      final url = Uri.parse('https://pokepast.es/57d8a74ecd26c17a/raw');
      final response = await http.get(url);
      final text = response.body;

      final pokepaste = parser.parse(text);

      final List<Pokemon> expectedMons = [
        Pokemon(
            name: 'Miraidon',
            ability: 'Hadron Engine',
            item: 'Choice Specs',
            level: 50,
            teraType: 'Electric',
            evs: Stats(specialAttack: 252, speed: 252),
            nature: 'Modest',
            moves: ['Electro Drift', 'Draco Meteor', 'Volt Switch', 'Discharge']
        ),
        Pokemon(
            name: 'Farigiraf',
            ability: 'Armor Tail',
            item: 'Electric Seed',
            gender: 'F',
            level: 54,
            teraType: 'Ground',
            ivs: Stats(attack: 0, speed: 31, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            evs: Stats(hp: 180, defense: 236, specialDefense: 92),
            nature: 'Bold',
            moves: ['Dazzling Gleam', 'Foul Play', 'Trick Room', 'Helping Hand']
        ),
        Pokemon(
            name: 'Landorus',
            ability: 'Sheer Force',
            item: 'Life Orb',
            level: 70,
            teraType: 'Steel',
            ivs: Stats(attack: 0, speed: 31, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            evs: Stats(specialAttack: 252, specialDefense: 100, speed: 156),
            nature: 'Timid',
            moves: ['Earth Power', 'Sludge Bomb', 'Taunt', 'Protect']
        ),
        Pokemon(
            name: 'Whimsicott',
            ability: 'Prankster',
            item: 'Focus Sash',
            gender: 'M',
            level: 50,
            teraType: 'Ghost',
            evs: Stats(hp: 4, defense: 44, specialAttack: 204, specialDefense: 4, speed: 252),
            ivs: Stats(attack: 0, speed: 31, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            nature: 'Timid',
            moves: ['Moonblast', 'Tailwind', 'Encore', 'Protect']
        ),
        Pokemon(
            name: 'Ogerpon-Cornerstone',
            ability: 'Sturdy',
            item: 'Cornerstone Mask',
            teraType: 'Rock',
            evs: Stats(attack: 252, speed: 252, hp: 4),
            nature: 'Adamant',
            moves: ['Ivy Cudgel', 'Horn Leech', 'Follow Me', 'Spiky Shield']
        ),
        Pokemon(
            name: 'Incineroar',
            ability: 'Intimidate',
            item: null,
            level: 50,
            teraType: 'Grass',
            evs: Stats(hp: 252, defense: 196, specialDefense: 60),
            ivs: Stats(attack: 31, speed: 29, specialAttack: 31, defense: 31, specialDefense: 31, hp: 31),
            nature: 'Impish',
            moves: ['Flare Blitz', 'Knock Off', 'Fake Out', 'U-turn']
        )];
      for (int i = 0; i < expectedMons.length; i++) {
        expect(pokepaste.pokemons[i], expectedMons[i]);
      }

      Pokepaste fromString = parser.parse(pokepaste.toString());
      for (int i = 0; i < pokepaste.pokemons.length; i++) {
        expect(fromString.pokemons[i], pokepaste.pokemons[i]);
      }
    });
  });
}
