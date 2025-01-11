import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart';

@JsonSerializable()
class Pokepaste {

  List<Pokemon> pokemons;

  Pokepaste(this.pokemons);

  factory Pokepaste.fromJson(Map<String, dynamic> json) => _$PokepasteFromJson(json);
  Map<String, dynamic> toJson() => _$PokepasteToJson(this);
}

@JsonSerializable()
class Pokemon {
  final String name;
  final String item;
  final String ability;
  final String level;
  final List<String> moves;
  final Stats? ivs;
  final Stats? evs;

  Pokemon({required this.name, required this.item, required this.ability, required this.level, required this.moves, this.ivs, required this.evs});


  factory Pokemon.fromJson(Map<String, dynamic> json) => _$PokemonFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}

@JsonSerializable()
class Stats {
  final int hp;
  final int speed;
  final int attack;
  final int specialAttack;
  final int defense;
  final int specialDefense;

  Stats({
    this.hp = 0,
    this.speed = 0,
    this.attack = 0,
    this.specialAttack = 0,
    this.defense = 0,
    this.specialDefense = 0
  });


  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatsToJson(this);
}