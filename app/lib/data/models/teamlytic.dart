import './replay.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
part 'teamlytic.g.dart';

@JsonSerializable()
class Teamlytic {
  String saveName;
  List<String> sdNames;
  List<Replay> replays;
  Pokepaste? pokepaste;

  Teamlytic({required this.saveName, required this.sdNames, required this.replays, required this.pokepaste});

  factory Teamlytic.fromJson(Map<String, dynamic> json) => _$TeamlyticFromJson(json);
  Map<String, dynamic> toJson() => _$TeamlyticToJson(this);
}

class TeamlyticPreview {
  final String saveName;
  final Pokepaste? pokepaste;

  TeamlyticPreview({required this.saveName, required this.pokepaste});

  TeamlyticPreview.from(Teamlytic teamlytic): this(saveName: teamlytic.saveName, pokepaste: teamlytic.pokepaste);

}