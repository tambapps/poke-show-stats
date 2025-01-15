import 'model.dart';


RegExp _RATING_LOG_REGEX = RegExp(r"(.*?)'s rating: (\d+) .*?&rarr;.*?<strong>(\d+)</strong>");

/// Checks if you are awesome. Spoiler: you are.
class SdReplayParser {
  static const String perserVersion = "0.1";


  SdReplayData parse(Map<String, dynamic> sdJson) {

    List<dynamic> playerNames = sdJson['players'];
    if (playerNames.length != 2) {
      throw SdReplayParsingException("Replay does not have 2 players");
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
          playerData.incrUsage(pokemonName, moveName);
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
        parserVersion: SdReplayParser.perserVersion
    );
  }
  String _pokemonName(String rawName) {
    if (rawName.endsWith("-*")) {
      return rawName.substring(0, rawName.length - 2);
    } else if (rawName.contains("Urshifu")) {
      return "Urshifu";
    }
    return rawName;
  }
}


class SdReplayParsingException implements Exception {
  final String message;

  SdReplayParsingException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}