import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart';

// yes, there isn't a list comparator in dart sdk...
bool listEquals<T>(List<T> l1, List<T> l2) { // note doesn't handle deep lists
  if (l1.length != l2.length) {
    return false;
  }
  for (int i = 0; i < l1.length; i++) {
    if (l1[i] != l2[i]) {
      return false;
    }
  }
  return true;
}

@JsonSerializable()
class Pokepaste {

  List<Pokemon> pokemons;
  String? url;

  Pokepaste(this.pokemons);

  factory Pokepaste.fromJson(Map<String, dynamic> json) => _$PokepasteFromJson(json);
  Map<String, dynamic> toJson() => _$PokepasteToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokepaste &&
          pokemons == other.pokemons;

  @override
  int get hashCode => pokemons.hashCode;

  @override
  String toString() {
    return 'Pokepaste{pokemons: $pokemons}';
  }
}

@JsonSerializable()
class Pokemon {
  String name;
  String? gender;
  String? item;
  String ability;
  String teraType;
  String nature;
  int level;
  List<String> moves;
  Stats? ivs;
  Stats? evs;

  Pokemon({
    this.name = "",
    this.gender,
    this.item,
    this.ability = "",
    this.teraType = "",
    this.nature = "",
    this.level = 50,
    this.moves = const [],
    this.ivs,
    this.evs
  });


  factory Pokemon.fromJson(Map<String, dynamic> json) => _$PokemonFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokemon &&
          name == other.name &&
          gender == other.gender &&
          item == other.item &&
          ability == other.ability &&
          teraType == other.teraType &&
          nature == other.nature &&
          level == other.level &&
          listEquals(moves, other.moves) &&
          ivs == other.ivs &&
          evs == other.evs;

  @override
  int get hashCode =>
      name.hashCode ^
      gender.hashCode ^
      item.hashCode ^
      ability.hashCode ^
      teraType.hashCode ^
      nature.hashCode ^
      level.hashCode ^
      moves.hashCode ^
      ivs.hashCode ^
      evs.hashCode;

  @override
  String toString() {
    return 'Pokemon{name: $name, gender: $gender, item: $item, ability: $ability, teraType: $teraType, nature: $nature, level: $level, moves: $moves, ivs: $ivs, evs: $evs}';
  }
}

@JsonSerializable()
class Stats {
  int hp;
  int speed;
  int attack;
  int specialAttack;
  int defense;
  int specialDefense;

  Stats({
    this.hp = 0,
    this.speed = 0,
    this.attack = 0,
    this.specialAttack = 0,
    this.defense = 0,
    this.specialDefense = 0
  });
  factory Stats.withDefault(int defaultValue) => Stats(
    hp: defaultValue,
    speed: defaultValue,
    attack: defaultValue,
    specialAttack: defaultValue,
    defense: defaultValue,
    specialDefense: defaultValue,
  );


  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatsToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stats &&
          hp == other.hp &&
          speed == other.speed &&
          attack == other.attack &&
          specialAttack == other.specialAttack &&
          defense == other.defense &&
          specialDefense == other.specialDefense;

  @override
  int get hashCode =>
      hp.hashCode ^
      speed.hashCode ^
      attack.hashCode ^
      specialAttack.hashCode ^
      defense.hashCode ^
      specialDefense.hashCode;

  @override
  String toString() {
    return 'Stats{hp: $hp, speed: $speed, attack: $attack, specialAttack: $specialAttack, defense: $defense, specialDefense: $specialDefense}';
  }
}