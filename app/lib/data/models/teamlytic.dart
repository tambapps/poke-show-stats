import 'package:poke_showstats/data/models/matchup.dart';

import './replay.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
part 'teamlytic.g.dart';

@JsonSerializable()
class Teamlytic {
  String saveName;
  String? teamNotes;
  List<String> sdNames;
  List<Replay> replays;
  List<MatchUp> matchUps;
  Pokepaste? pokepaste;
  int lastUpdatedAt;

  Teamlytic({required this.saveName, required this.sdNames, required this.replays, required this.matchUps, required this.pokepaste, required this.lastUpdatedAt, required this.teamNotes});

  factory Teamlytic.fromJson(Map<String, dynamic> json) => _$TeamlyticFromJson(json);
  Map<String, dynamic> toJson() => _$TeamlyticToJson(this);
}

class TeamlyticPreview {
  final String saveName;
  final Pokepaste? pokepaste;
  int lastUpdatedAt;

  TeamlyticPreview({required this.saveName, required this.pokepaste, required this.lastUpdatedAt});

  TeamlyticPreview.from(Teamlytic teamlytic): this(saveName: teamlytic.saveName, pokepaste: teamlytic.pokepaste, lastUpdatedAt: teamlytic.lastUpdatedAt);

}