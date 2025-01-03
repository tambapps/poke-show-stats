import 'package:sd_replay_parser/sd_replay_parser.dart';

class Replay {
  final Uri uri;
  final SdReplayData data;
  final String? notes;

  Replay({required this.uri, required this.data, this.notes});
}