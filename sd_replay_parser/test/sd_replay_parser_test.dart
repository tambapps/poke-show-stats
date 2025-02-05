import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  group('Replay parser test', () {
    final parser = SdReplayParser();

    setUp(() {
      // Additional setup goes here.
    });

    test('Decode test', () async {
      final url = Uri.parse('https://replay.pokemonshowdown.com/gen9vgc2025reggbo3-2273645736-8ub0nqh6dg1kywuy7y37h77mr4pw8qhpw.json');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final replay = parser.parse(data);
      expect(replay.formatId, equals('gen9vgc2025reggbo3'));
      expect(replay.rating, equals(1288));
      expect(replay.uploadTime, equals(1735820009));

      PlayerData player1 = replay.player1;
      expect(player1.leads, ['rillaboom', 'raging-bolt'], reason: 'Player 1 has incorrect leads');
      expect(player1.selection, ['rillaboom', 'raging-bolt', 'calyrex-shadow', 'ogerpon-hearthflame']);
      expect(player1.team, [
        'calyrex-shadow',
        'incineroar',
        'rillaboom',
        'urshifu',
        'raging-bolt',
        'ogerpon-hearthflame'
      ]);
      expect(player1.terastallization, Terastallization(pokemon: 'raging-bolt', type: 'Electric'));
      expect(player1.beforeElo, 1358);
      expect(player1.afterElo, 1332);

      PlayerData player2 = replay.player2;
      expect(player2.leads, ['miraidon', 'entei'], reason: 'Player 2 has incorrect leads');
      expect(player2.selection, ['miraidon', 'entei', 'whimsicott', 'chien-pao']);
      expect(player2.team, [
        'miraidon',
        'entei',
        'chien-pao',
        'iron-hands',
        'whimsicott',
        'ogerpon-cornerstone'
      ]);
      expect(player2.terastallization, Terastallization(pokemon: 'entei', type: 'Normal'));
      expect(player2.beforeElo, 1256);
      expect(player2.afterElo, 1288);

      expect(replay.winner, 'jarmanvgc');
      expect(replay.winnerPlayer, player2);
      print(player1.moveUsages);
    });
  });
}
