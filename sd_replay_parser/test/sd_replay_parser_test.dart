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
      final url = Uri.parse('https://replay.pokemonshowdown.com/gen9vgc2025reggbo3-2275124329-bo28iiemskpx8pjidgu6sh23uysvkzypw.json');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final replay = parser.parse(data);
      expect(replay.formatId, equals('gen9vgc2025reggbo3'));
      expect(replay.rating, equals(1288));
      expect(replay.uploadTime, equals(1735820009));

      PlayerData player1 = replay.player1;
      expect(player1.leads, ['Rillaboom', 'Raging Bolt'], reason: 'Player 1 has incorrect leads');
      expect(player1.selection, ['Rillaboom', 'Raging Bolt', 'Calyrex-Shadow', 'Ogerpon-Hearthflame']);
      expect(player1.team, [
        'Calyrex-Shadow',
        'Incineroar',
        'Rillaboom',
        'Urshifu',
        'Raging Bolt',
        'Ogerpon-Hearthflame'
      ]);
      expect(player1.terastallization, Terastallization(pokemon: 'Raging Bolt', type: 'Electric'));
      expect(player1.beforeElo, 1358);
      expect(player1.afterElo, 1332);

      PlayerData player2 = replay.player2;
      expect(player2.leads, ['Miraidon', 'Entei'], reason: 'Player 2 has incorrect leads');
      expect(player2.selection, ['Miraidon', 'Entei', 'Whimsicott', 'Chien-Pao']);
      expect(player2.team, [
        'Miraidon',
        'Entei',
        'Chien-Pao',
        'Iron Hands',
        'Whimsicott',
        'Ogerpon-Cornerstone'
      ]);
      expect(player2.terastallization, Terastallization(pokemon: 'Entei', type: 'Normal'));
      expect(player2.beforeElo, 1256);
      expect(player2.afterElo, 1288);

      expect(replay.winner, 'jarmanvgc');
      expect(replay.winnerPlayer, player2);
      print(player1.moveUsages);
    });
  });
}
