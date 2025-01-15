// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Replay _$ReplayFromJson(Map<String, dynamic> json) => Replay(
      uri: Uri.parse(json['uri'] as String),
      data: SdReplayData.fromJson(json['data'] as Map<String, dynamic>),
      gameOutput: $enumDecode(_$GameOutputEnumMap, json['gameOutput']),
      opposingPlayer:
          PlayerData.fromJson(json['opposingPlayer'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ReplayToJson(Replay instance) => <String, dynamic>{
      'uri': instance.uri.toString(),
      'data': instance.data,
      'notes': instance.notes,
      'gameOutput': _$GameOutputEnumMap[instance.gameOutput]!,
      'opposingPlayer': instance.opposingPlayer,
    };

const _$GameOutputEnumMap = {
  GameOutput.WIN: 'WIN',
  GameOutput.LOSS: 'LOSS',
  GameOutput.UNKNOWN: 'UNKNOWN',
};
