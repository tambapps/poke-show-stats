import 'package:json_annotation/json_annotation.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
part 'replay.g.dart';

@JsonSerializable()
class Replay {
  final Uri uri;
  final SdReplayData data;
  final String? notes;
  final GameOutput gameOutput;
  final PlayerData opposingPlayer;

  // other because it may not be self, if the match doesn't stare self
  PlayerData get otherPlayer => data.player1.name == opposingPlayer.name ? data.player2 : data.player1;

  Replay({required this.uri, required this.data, required this.gameOutput,
    required this.opposingPlayer,
    this.notes});

  factory Replay.fromJson(Map<String, dynamic> json) => _$ReplayFromJson(json);
  Map<String, dynamic> toJson() => _$ReplayToJson(this);
}

enum GameOutput {
  WIN, LOSS, UNKNOWN
}