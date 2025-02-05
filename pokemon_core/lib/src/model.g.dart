// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
      name: json['name'] as String? ?? "",
      gender: json['gender'] as String?,
      item: json['item'] as String?,
      ability: json['ability'] as String? ?? "",
      teraType: json['teraType'] as String? ?? "",
      nature: json['nature'] as String?,
      level: (json['level'] as num?)?.toInt(),
      moves:
          (json['moves'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      ivs: json['ivs'] == null
          ? null
          : Stats.fromJson(json['ivs'] as Map<String, dynamic>),
      evs: json['evs'] == null
          ? null
          : Stats.fromJson(json['evs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
      'name': instance.name,
      'gender': instance.gender,
      'item': instance.item,
      'ability': instance.ability,
      'teraType': instance.teraType,
      'nature': instance.nature,
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
