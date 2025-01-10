import 'package:freezed_annotation/freezed_annotation.dart';
part 'sd_replay_parser_base.g.dart';

RegExp _RATING_LOG_REGEX = RegExp(r"(.*?)'s rating: (\d+) .*?&rarr;.*?<strong>(\d+)</strong>");

const String PARSER_VERSION = "0.1";
/// Checks if you are awesome. Spoiler: you are.
class SdReplayParser {


  SdReplayData parse(Map<String, dynamic> sdJson) {

    List<dynamic> playerNames = sdJson['players'];
    if (playerNames.length != 2) {
      throw ParsingException("Replay does not have 2 players");
    }

    List<PlayerData> playerDataList = [PlayerData.name(playerNames[0].toString()), PlayerData.name(playerNames[1].toString())];

    String winner = '';
    List<String> logs = sdJson['log'].toString().split('\n');
    for (String log in logs) {
      final List<String> tokens = log.split("|");
      if (tokens.length < 2) continue;
      PlayerData playerData = playerDataList[tokens.length > 2 && tokens[2].startsWith('p2') ? 1 : 0];
      switch(tokens[1]) {
        case "move":
          final String pokemonName = _pokemonName(tokens[2].split(':').last.trim()); // e.g. p1a: Rillaboom
          final String moveName = tokens[3];
          playerData._incrUsage(pokemonName, moveName);
          break;
        case "poke":
          playerData.team.add(_pokemonName(tokens[3].split(',').first)); // e.g. Chien-Pao, L50
          break;
        case "raw":
          var match = _RATING_LOG_REGEX.firstMatch(log.substring(5));
          if (match != null) {
            // Extract the name, first number, and second number
            String name = match.group(1)!;
            int beforeRating = int.parse(match.group(2)!);
            int afterRating = int.parse(match.group(3)!);
            playerData = name == playerDataList.first.name ? playerDataList.first : playerDataList.last;
            playerData.beforeRating = beforeRating;
            playerData.afterRating = afterRating;
          }
          break;
        case "drag":
        case "switch":
          // we want a list to keep track of leads and still have unique elements
          String pokemon = _pokemonName(tokens[3].split(',')[0]); // e.g. "Rillaboom, L50, F"
          if (!playerData.selection.contains(pokemon)) {
            playerData.selection.add(pokemon);
          }
          break;
        case "-terastallize":
          playerData.terastallization = Terastallization(
            pokemon: _pokemonName(tokens[2].split(':').last.trim()),
            type: tokens[3]
          );
          break;
        case "win":
          winner = tokens[2];
          break;
      }
    }

    return SdReplayData(
        player1: playerDataList.first,
        player2: playerDataList.last,
        uploadTime: sdJson['uploadtime'],
        formatId: sdJson['formatid'],
        rating: sdJson['rating'],
        winner: winner,
        parserVersion: PARSER_VERSION
    );
  }
  String _pokemonName(String rawName) {
    if (rawName.contains("Urshifu")) return "Urshifu";
    return rawName;
  }
}

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
  int? beforeRating;
  int? afterRating;
  List<String> get leads => selection.sublist(0, 2);
  Terastallization? terastallization;
  // pokemonName -> moveName -> count
  final Map<String, Map<String, int>> moveUsages;

  PlayerData.name(String name): this(name: name, team: [], selection: [], moveUsages: {},);

  PlayerData({required this.name, required this.team, required this.selection, this.beforeRating,
    this.afterRating, this.terastallization, required this.moveUsages});


  void _incrUsage(String pokemonName, String moveName) {
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

  PlayerData get winnerPlayer => player1.name == winner ? player1 : player2;

  SdReplayData({
    required this.player1, required this.player2, required this.uploadTime, required this.formatId,
    required this.rating, required this.parserVersion,
    required this.winner
  });

  PlayerData? getPlayer(String playerName) {
    if (player1.name == playerName) return player1;
    if (player2.name == playerName) return player2;
    return null;
  }

  factory SdReplayData.fromJson(Map<String, dynamic> json) => _$SdReplayDataFromJson(json);
  Map<String, dynamic> toJson() => _$SdReplayDataToJson(this);
}

class ParsingException implements Exception {
  final String message;

  ParsingException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}