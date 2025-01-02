import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  group('A group of tests', () {
    final parser = SdReplayParser();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      final url = Uri.parse('https://replay.pokemonshowdown.com/gen9vgc2025reggbo3-2273645736-8ub0nqh6dg1kywuy7y37h77mr4pw8qhpw.json');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final replay = parser.parse(data);
      print(replay.leads);
      expect(replay.players, equals(['SlimReaperVGC', 'jarmanvgc']));
      expect(replay.formatId, equals('gen9vgc2025reggbo3'));
      expect(replay.rating, equals(1288));
      expect(replay.uploadTime, equals(1735820009));
      expect(replay.leads, {'SlimReaperVGC': ['Rillaboom', 'Raging Bolt'], 'jarmanvgc': ['Miraidon', 'Entei']});
      expect(replay.winner, 'jarmanvgc');
    });
  });
}
