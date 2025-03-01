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
    StringBuffer buffer = StringBuffer();
    for (Pokemon pokemon in pokemons) {
      buffer.write(pokemon.name);
      if (pokemon.gender != null) {
        buffer.write(" (${pokemon.gender})");
      }
      if (pokemon.item != null) {
        buffer.write(" @ ${pokemon.item}");
      }
      buffer.writeln();
      buffer.writeln("Ability: ${pokemon.ability}");
      if (pokemon.level != null) {
        buffer.writeln("Level: ${pokemon.level}");
      }
      buffer.writeln("Tera Type: ${pokemon.teraType}");
      Stats evs = pokemon.evs ?? Stats.withDefault(0);
      buffer.writeln("EVs: ${_statsToString(evs)}");
      if (pokemon.nature != null) {
        buffer.writeln("${pokemon.nature} Nature");
      }
      if (pokemon.ivs != null && pokemon.ivs != Stats.withDefault(31)) {
        buffer.writeln("IVs: ${_statsToString(pokemon.ivs!)}");
      }
      for (String move in pokemon.moves) {
        buffer.writeln("- $move");
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _statsToString(Stats stats) {
    return "${stats.hp} HP / ${stats.attack} Atk / ${stats.defense} Def / ${stats.specialAttack} SpA / ${stats.specialDefense} SpD / ${stats.speed} Spe";
  }
}

