import 'package:json_annotation/json_annotation.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
part 'matchup.g.dart';

@JsonSerializable()
class MatchUp {

  String? name;
  Pokepaste? pokepaste;
  String? notes;

  MatchUp({required this.name, required this.pokepaste, required this.notes});

  factory MatchUp.fromJson(Map<String, dynamic> json) => _$MatchUpFromJson(json);
  Map<String, dynamic> toJson() => _$MatchUpToJson(this);
}