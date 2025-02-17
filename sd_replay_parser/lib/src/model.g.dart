// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Terastallization _$TerastallizationFromJson(Map<String, dynamic> json) =>
    Terastallization(
      pokemon: json['pokemon'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TerastallizationToJson(Terastallization instance) =>
    <String, dynamic>{
      'pokemon': instance.pokemon,
      'type': instance.type,
    };

PlayerData _$PlayerDataFromJson(Map<String, dynamic> json) => PlayerData(
      name: json['name'] as String,
      team: (json['team'] as List<dynamic>).map((e) => e as String).toList(),
      selection:
          (json['selection'] as List<dynamic>).map((e) => e as String).toList(),
      beforeElo: (json['beforeElo'] as num?)?.toInt(),
      afterElo: (json['afterElo'] as num?)?.toInt(),
      terastallization: json['terastallization'] == null
          ? null
          : Terastallization.fromJson(
              json['terastallization'] as Map<String, dynamic>),
      pokepaste: json['pokepaste'] == null
          ? null
          : Pokepaste.fromJson(json['pokepaste'] as Map<String, dynamic>),
      moveUsages: (json['moveUsages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
      ),
    );

Map<String, dynamic> _$PlayerDataToJson(PlayerData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'team': instance.team,
      'selection': instance.selection,
      'beforeElo': instance.beforeElo,
      'afterElo': instance.afterElo,
      'terastallization': instance.terastallization,
      'pokepaste': instance.pokepaste,
      'moveUsages': instance.moveUsages,
    };

SdReplayData _$SdReplayDataFromJson(Map<String, dynamic> json) => SdReplayData(
      player1: PlayerData.fromJson(json['player1'] as Map<String, dynamic>),
      player2: PlayerData.fromJson(json['player2'] as Map<String, dynamic>),
      uploadTime: (json['uploadTime'] as num).toInt(),
      formatId: json['formatId'] as String,
      rating: (json['rating'] as num?)?.toInt(),
      parserVersion: json['parserVersion'] as String,
      winner: json['winner'] as String,
      nextBattle: json['nextBattle'] as String?,
    );

Map<String, dynamic> _$SdReplayDataToJson(SdReplayData instance) =>
    <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'uploadTime': instance.uploadTime,
      'formatId': instance.formatId,
      'rating': instance.rating,
      'parserVersion': instance.parserVersion,
      'winner': instance.winner,
      'nextBattle': instance.nextBattle,
    };
