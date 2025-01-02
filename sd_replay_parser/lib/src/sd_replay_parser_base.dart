// TODO: Put public facing types in this file.

import 'dart:ffi';
import 'dart:math';

const String PARSER_VERSION = "0.1";
/// Checks if you are awesome. Spoiler: you are.
class SdReplayParser {

  SdReplay parse(Map<String, dynamic> sdJson) {

    List<dynamic> players = sdJson['players'];
    if (players.length != 2) {
      throw ParsingException("Replay does not have 2 players");
    }
    List<String> logs = sdJson['log'].toString().split('\n');
    Map<String, dynamic> moveUsages = {};
    Map<String, List<String>> leads = {};
    String winner = '';
    for (String log in logs) {
      print(log);
      final List<String> tokens = log.split("|");
      if (tokens.length < 2) continue;

      switch(tokens[1]) {
        case "switch":
          // listen to this event for leads
          final index = int.parse(tokens[2][1]) - 1;
          final List<String> playerLeads = leads.putIfAbsent(players[index], () => []);
          if (playerLeads.length < 2) {
            playerLeads.add(_pokemonName(tokens[3].split(',')[0]));
          }
          break;
        case "win":
          winner = tokens[2];
          break;
      }
    }

    return SdReplay(
        players: players.map((e) => e.toString()).toList(),
        uploadTime: sdJson['uploadtime'],
        formatId: sdJson['formatid'],
        rating: sdJson['rating'],
        leads: leads,
        moveUsages: moveUsages,
        winner: winner,
        parserVersion: PARSER_VERSION
    );
  }

  String _pokemonName(String rawName) => rawName;
}


class SdReplay {
  final List<String> players;
  final int uploadTime;
  final String formatId;
  final int rating;
  final String parserVersion;
  // playerName -> pokemonName -> moveName -> count
  final Map<String, dynamic> moveUsages;
  // playerName -> List<pokemonName>
  final Map<String, List<String>> leads;
  final String winner;

  SdReplay({
    required this.players, required this.uploadTime, required this.formatId,
    required this.rating, required this.parserVersion, required this.moveUsages,
    required this.leads, required this.winner
  });
}

class ParsingException implements Exception {
  final String message;

  ParsingException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}