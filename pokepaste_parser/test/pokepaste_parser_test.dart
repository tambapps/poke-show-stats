import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  group('Replay parser test', () {
    final parser = PokepasteParser();

    setUp(() {
      // Additional setup goes here.
    });

    test('Parse test', () async {
      final url = Uri.parse('https://pokepast.es/c5eeb30641e39b79/raw');
      final response = await http.get(url);
      final text = response.body;
      print(text);
    });
  });
}
