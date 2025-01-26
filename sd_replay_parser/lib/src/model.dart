import 'package:json_annotation/json_annotation.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
part 'model.g.dart';

@JsonSerializable()
class Terastallization {
  final String pokemon;
  final String type;
  const Terastallization({
    required this.pokemon,
    required this.type,
  });

  factory Terastallization.fromJson(Map<String, dynamic> json) => _$TerastallizationFromJson(json);
  Map<String, dynamic> toJson() => _$TerastallizationToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Terastallization &&
              runtimeType == other.runtimeType &&
              pokemon == other.pokemon &&
              type == other.type;

  @override
  int get hashCode => pokemon.hashCode ^ type.hashCode;
}

@JsonSerializable()
class PlayerData {
  final String name;
  final List<String> team;
  final List<String> selection;
  int? beforeElo;
  int? afterElo;
  List<String> get leads => selection.sublist(0, 2);
  Terastallization? terastallization;
  Pokepaste? pokepaste;
  // pokemonName -> moveName -> count
  final Map<String, Map<String, int>> moveUsages;

  PlayerData.name(String name): this(name: name, team: [], selection: [], moveUsages: {},);

  PlayerData({required this.name, required this.team, required this.selection, this.beforeElo,
    this.afterElo, this.terastallization, this.pokepaste, required this.moveUsages});


  void incrUsage(String pokemonName, String moveName) {
    final Map<String, int> moveMap = moveUsages.putIfAbsent(pokemonName, () => {});
    moveMap.update(moveName, (count) => count + 1, ifAbsent: () => 1);
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) => _$PlayerDataFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);

}

@JsonSerializable()
class SdReplayData {
  final PlayerData player1;
  final PlayerData player2;
  final int uploadTime;
  final String formatId;
  final int? rating;
  final String parserVersion;
  final String winner;
  final String? nextBattle;
  bool get isOts => player1.pokepaste != null && player2.pokepaste != null;

  PlayerData get winnerPlayer => player1.name == winner ? player1 : player2;

  SdReplayData({
    required this.player1, required this.player2, required this.uploadTime, required this.formatId,
    required this.rating, required this.parserVersion,
    required this.winner, required this.nextBattle
  });

  PlayerData? getPlayer(String playerName) {
    if (player1.name == playerName) return player1;
    if (player2.name == playerName) return player2;
    return null;
  }

  factory SdReplayData.fromJson(Map<String, dynamic> json) => _$SdReplayDataFromJson(json);
  Map<String, dynamic> toJson() => _$SdReplayDataToJson(this);
}