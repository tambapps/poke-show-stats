// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teamlytic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teamlytic _$TeamlyticFromJson(Map<String, dynamic> json) => Teamlytic(
      saveName: json['saveName'] as String,
      sdNames:
          (json['sdNames'] as List<dynamic>).map((e) => e as String).toList(),
      replays: (json['replays'] as List<dynamic>)
          .map((e) => Replay.fromJson(e as Map<String, dynamic>))
          .toList(),
      pokepaste: json['pokepaste'] == null
          ? null
          : Pokepaste.fromJson(json['pokepaste'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamlyticToJson(Teamlytic instance) => <String, dynamic>{
      'saveName': instance.saveName,
      'sdNames': instance.sdNames,
      'replays': instance.replays,
      'pokepaste': instance.pokepaste,
    };
