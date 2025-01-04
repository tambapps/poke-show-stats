// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Replay _$ReplayFromJson(Map<String, dynamic> json) => Replay(
      uri: Uri.parse(json['uri'] as String),
      data: SdReplayData.fromJson(json['data'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ReplayToJson(Replay instance) => <String, dynamic>{
      'uri': instance.uri.toString(),
      'data': instance.data,
      'notes': instance.notes,
    };
