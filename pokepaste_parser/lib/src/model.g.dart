// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokepaste _$PokepasteFromJson(Map<String, dynamic> json) => Pokepaste(
      (json['pokemons'] as List<dynamic>)
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PokepasteToJson(Pokepaste instance) => <String, dynamic>{
      'pokemons': instance.pokemons,
    };

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
      name: json['name'] as String,
      item: json['item'] as String,
      ability: json['ability'] as String,
      level: json['level'] as String,
      moves: (json['moves'] as List<dynamic>).map((e) => e as String).toList(),
      ivs: json['ivs'] == null
          ? null
          : Stats.fromJson(json['ivs'] as Map<String, dynamic>),
      evs: json['evs'] == null
          ? null
          : Stats.fromJson(json['evs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
      'name': instance.name,
      'item': instance.item,
      'ability': instance.ability,
      'level': instance.level,
      'moves': instance.moves,
      'ivs': instance.ivs,
      'evs': instance.evs,
    };

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      hp: (json['hp'] as num?)?.toInt() ?? 0,
      speed: (json['speed'] as num?)?.toInt() ?? 0,
      attack: (json['attack'] as num?)?.toInt() ?? 0,
      specialAttack: (json['specialAttack'] as num?)?.toInt() ?? 0,
      defense: (json['defense'] as num?)?.toInt() ?? 0,
      specialDefense: (json['specialDefense'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'hp': instance.hp,
      'speed': instance.speed,
      'attack': instance.attack,
      'specialAttack': instance.specialAttack,
      'defense': instance.defense,
      'specialDefense': instance.specialDefense,
    };
