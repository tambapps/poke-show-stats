import 'package:json_annotation/json_annotation.dart';
import 'package:pokemon_core/pokemon_core.dart';
part 'model.g.dart';

@JsonSerializable()
class Pokepaste {

  List<Pokemon> pokemons;
  String? url;

  Pokepaste(this.pokemons);

  factory Pokepaste.fromJson(Map<String, dynamic> json) => _$PokepasteFromJson(json);
  Map<String, dynamic> toJson() => _$PokepasteToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokepaste &&
          pokemons == other.pokemons;

  @override
  int get hashCode => pokemons.hashCode;

  @override
  String toString() {
    return 'Pokepaste{pokemons: $pokemons}';
  }
}

