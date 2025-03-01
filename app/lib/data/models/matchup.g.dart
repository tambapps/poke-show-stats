// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matchup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchUp _$MatchUpFromJson(Map<String, dynamic> json) => MatchUp(
      name: json['name'] as String?,
      pokepaste: json['pokepaste'] == null
          ? null
          : Pokepaste.fromJson(json['pokepaste'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MatchUpToJson(MatchUp instance) => <String, dynamic>{
      'name': instance.name,
      'pokepaste': instance.pokepaste,
      'notes': instance.notes,
    };
