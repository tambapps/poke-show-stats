import 'package:pokemon_core/pokemon_core.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import 'model.dart';


RegExp _RATING_LOG_REGEX = RegExp(r"(.*?)'s rating: (\d+) .*?&rarr;.*?<strong>(\d+)</strong>");
RegExp _NEXT_BATTLE_REGEX = RegExp(r'href="([^"]+)"');

/// Checks if you are awesome. Spoiler: you are.
class SdReplayParser {
  static const String parserVersion = "0.1";


  SdReplayData parse(Map<String, dynamic> sdJson) {

    List<dynamic> playerNames = sdJson['players'];
    if (playerNames.length != 2) {
      throw SdReplayParsingException("Replay does not have 2 players");
    }

    List<PlayerData> playerDataList = [PlayerData.name(playerNames[0].toString()), PlayerData.name(playerNames[1].toString())];

    String winner = '';
    String? nextBattle;
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
        case "uhtml":
          var match = _NEXT_BATTLE_REGEX.firstMatch(log.substring(5));
          if (match != null) {
            nextBattle = match.group(1);
            if (nextBattle != null && nextBattle.contains("-gen")) {
              nextBattle = nextBattle.substring(nextBattle.indexOf("-gen") + 1);
            }
          }
        case "raw":
          var match = _RATING_LOG_REGEX.firstMatch(log.substring(5));
          if (match != null) {
            // Extract the name, first number, and second number
            String name = match.group(1)!;
            int beforeElo = int.parse(match.group(2)!);
            int afterElo = int.parse(match.group(3)!);
            playerData = name == playerDataList.first.name ? playerDataList.first : playerDataList.last;
            playerData.beforeElo = beforeElo;
            playerData.afterElo = afterElo;
          }
          break;
        case "drag":
        case "switch":
          // we want a list to keep track of leads and still have unique elements
          String pokemon = _pokemonName(tokens[3].split(',')[0]); // e.g. "Rillaboom, L50, F"
          if (!playerData.selection.contains(pokemon) && pokemon != "Terapagos-Stellar") {
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
        case "showteam":
          String teamLog = log.substring(13);
          List<String> pokemonLog = teamLog.split("]");
          playerData.pokepaste = Pokepaste(pokemonLog.map(_parsePokemonOts).toList());
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
        nextBattle: nextBattle,
        parserVersion: SdReplayParser.parserVersion
    );
  }
  String _pokemonName(String rawName) {
    if (rawName.endsWith("-*")) {
      rawName = rawName.substring(0, rawName.length - 2);
    }
    return Pokemon.normalize(rawName);
  }

  Pokemon _parsePokemonOts(String pokemonLog) {
    Pokemon pokemon = Pokemon();
    List<String> fields = pokemonLog.split("|");
    pokemon.name = fields[0];
    pokemon.item = _formattedShowteamName(fields[2]);
    pokemon.ability = _formattedShowteamName(fields[3]);
    pokemon.moves = fields[4].split(",").map(_formattedShowteamName).toList();
    pokemon.level = int.tryParse(fields[10]);
    pokemon.teraType = fields[11].split(",").last;
    return pokemon;
  }

  String _formattedShowteamName(String input) {
    StringBuffer buffer = StringBuffer(input[0]);
    for (int i = 1; i < input.length; i++) {
      String c = input[i];
      String last = input[i - 1];
      if (c.isUpperCase() && last != '-') {
        buffer.write(" ");
        buffer.write(c);
      } else if (c == '-') {
        buffer.write(' ');
      } else {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }
}

extension Case on String {
  // isuppercase
  bool isUpperCase(){
    int ascii = codeUnitAt(0);
    return ascii >= 65 && ascii <= 90;
  }
  // islowercase
  bool isLowerCase(){
    int ascii = codeUnitAt(0);
    return ascii >= 97 && ascii <= 122;
  }
}

class SdReplayParsingException implements Exception {
  final String message;

  SdReplayParsingException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}