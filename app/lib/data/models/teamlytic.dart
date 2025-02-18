import './replay.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
part 'teamlytic.g.dart';

abstract class ITeamlytic {
  String get saveName;

  List<String> get sdNames;
  set sdNames(List<String> value);

  List<Replay> get replays;
  set replays(List<Replay> value);

  Pokepaste? get pokepaste;
  set pokepaste(Pokepaste? value);

  int get lastUpdatedAt;
  set lastUpdatedAt(int value);
}

@JsonSerializable()
class Teamlytic extends ITeamlytic {
  @override
  String saveName;
  @override
  List<String> sdNames;
  @override
  List<Replay> replays;
  @override
  Pokepaste? pokepaste;
  @override
  int lastUpdatedAt;

  Teamlytic({required this.saveName, required this.sdNames, required this.replays, required this.pokepaste, required this.lastUpdatedAt});

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