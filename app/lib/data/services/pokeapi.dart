import 'dart:convert';
import 'package:http/http.dart' as http;


class PokeApi {
  static const _baseUrl = "https://pokeapi.co/api/v2";

  Future<Move?> getMove(String move) async {
    final response = await http.get(Uri.parse("$_baseUrl/move/${move.toLowerCase().replaceAll(' ', '-')}"));
    if (response.statusCode != 200) {
      return null;
    }
    Map<dynamic, dynamic> json = jsonDecode(response.body);
    return Move(name: json['name'], category: json['damage_class']['name'], type: json['type']['name']);
  }
}


class Move {
  final String name;
  final String category; //
  final String type;

  Move({required this.name, required this.category, required this.type});
}

