
import 'package:json_annotation/json_annotation.dart';

import 'collection_utils.dart';
part 'model.g.dart';

@JsonSerializable()
class Pokemon {
  static bool nameMatch(String s1, String s2) {
    // TODO handle form matches. E.g. urshifu should match urshifu sinle strike and urshifu rapid strike
    return Pokemon.normalize(s1) == Pokemon.normalize(s2);
  }

  static String? normalizeNullable(String? s) => s != null ? normalize(s) : null;

  static String normalize(String s) => s.toLowerCase().replaceAll(' ', '-');

  static String normalizeToBase(String input) {
    String s = normalize(input);
    // TODO handle all special forms
    // TODO could be optimized using a tree search?
    if (s.startsWith("urshifu")) {
      return "urshifu";
    } else if (s.startsWith("ogerpon")) {
      return "ogerpon";
    } else if (s.endsWith("-galar")) {
      return s.substring(0, s.length - 6);
    } else if (s.endsWith("-alola")) {
      return s.substring(0, s.length - 6);
    } else if (s.endsWith("-paldea")) {
      // because of Tauros-Paldea-Aqua
      return s.substring(0, s.indexOf("-paldea"));
    } else if (s.endsWith("-incarnate")) {
      return s.substring(0, s.length - 10);
    } else if (s.startsWith("ursaluna")) {
      return "ursaluna";
    } else if (s.startsWith("rotom")) {
      return "rotom";
    } else if (s.startsWith("terapagos")) {
      return "terapagos";
    } else if (s.startsWith("zamazenta")) {
      return "zamazenta";
    } else if (s.startsWith("zacian")) {
      return "zacian";
    } else if (s.startsWith("necrozma")) {
      return "necrozma";
    } else if (s.startsWith("calyrex")) {
      return "calyrex";
    } else if (s.startsWith("kyurem")) {
      return "kyurem";
    }
    return s;
  }

  String name;
  String? gender;
  String? item;
  String ability;
  String teraType;
  String? nature;
  int? level;
  List<String> moves;
  Stats? ivs;
  Stats? evs;

  Pokemon({
    this.name = "",
    this.gender,
    this.item,
    this.ability = "",
    this.teraType = "",
    this.nature,
    this.level,
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

  bool all(bool Function(int) predicate) => predicate(hp) && predicate(speed)
      && predicate(attack) && predicate(defense) && predicate(specialAttack) && predicate(specialDefense);

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