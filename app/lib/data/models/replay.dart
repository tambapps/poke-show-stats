import 'package:json_annotation/json_annotation.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
part 'replay.g.dart';

@JsonSerializable()
class Replay {
  final Uri uri;
  final SdReplayData data;
  String? notes;
  final GameOutput gameOutput;
  final PlayerData opposingPlayer;

  // other because it may not be self, if the match doesn't stare self
  PlayerData get otherPlayer => data.player1.name == opposingPlayer.name ? data.player2 : data.player1;

  Replay({required this.uri, required this.data, required this.gameOutput,
    required this.opposingPlayer,
    this.notes});

  factory Replay.fromJson(Map<String, dynamic> json) => _$ReplayFromJson(json);
  Map<String, dynamic> toJson() => _$ReplayToJson(this);

  bool isNextBattleOf(Replay other) => other.data.nextBattle != null && uri.toString().contains(other.data.nextBattle!);

  void trySetElo(List<Replay> replays) {
    if (data.nextBattle == null) {
      return;
    }
    for (Replay replay in replays) {
      if (replay.uri.toString().contains(data.nextBattle!)) {
        // always using before because the player did not win/loose yet
        data.player1.beforeElo = replay.data.player1.beforeElo;
        data.player1.afterElo = replay.data.player1.beforeElo;
        data.player2.beforeElo = replay.data.player2.beforeElo;
        data.player2.afterElo = replay.data.player2.beforeElo;
      }
    }
  }
}

enum GameOutput {
  WIN, LOSS, UNKNOWN
}