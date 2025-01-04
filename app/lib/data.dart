import 'package:json_annotation/json_annotation.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
part 'data.g.dart';

@JsonSerializable()
class Replay {
  final Uri uri;
  final SdReplayData data;
  final String? notes;

  Replay({required this.uri, required this.data, this.notes});

  factory Replay.fromJson(Map<String, dynamic> json) => _$ReplayFromJson(json);
  Map<String, dynamic> toJson() => _$ReplayToJson(this);
}