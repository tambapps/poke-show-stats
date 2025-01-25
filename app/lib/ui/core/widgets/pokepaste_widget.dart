import 'package:app2/data/services/pokemon_resource_service.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/utils.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../pokeutils.dart';

class PokepasteWidget extends AbstractStatelessWidget {

  final Pokepaste pokepaste;
  final PokemonResourceService pokemonResourceService;

  const PokepasteWidget({super.key, required this.pokepaste, required this.pokemonResourceService});

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    if (isMobile(context)) {
      return Column(
        children: pokepaste.pokemons.map((pokemon) => pokemonWidget(dimens, pokemon)).toList(),
      );
    }
    // desktop
    final pokemons = pokepaste.pokemons;
    List<Row> pokemonRows = [];
    int nbRows = (pokemons.length % 3 == 0 ? pokemons.length / 2 : pokemons.length / 2 + 1).toInt();
    for (int row = 0; row < nbRows; row++) {
      List<Widget> rowChildren = [];
      for (int i = row * 3; i < row * 3 + 3 && i < pokemons.length; i++) {
        rowChildren.add(Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: pokemonWidget(dimens, pokemons[i]),),));
      }
      pokemonRows.add(Row(children: rowChildren,));
    }
    return Column(children: pokemonRows,);
  }


  Widget pokemonWidget(Dimens dimens, Pokemon pokemon) {
    Widget moveWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pokemon.moves.map((move) => _moveWidget(move)).toList(),
    );
    return SizedBox(
      height: dimens.pokepastePokemonHeight,
      child: Row(
        children: [
          Expanded(
            flex: dimens.pokemonArtworkFlex,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 0.65,
                  child: pokemonResourceService.getPokemonArtwork(pokemon.name),
                ),
                Positioned(
                  top: dimens.pokepastePokemonIconsOffset,
                  left: 0,
                  child: pokemonResourceService.getTeraTypeSprite(pokemon.teraType, width: Dimens.teraSpriteSize, height: Dimens.teraSpriteSize),
                ),
                if (pokemon.item != null) Positioned(
                  bottom: dimens.pokepastePokemonIconsOffset,
                  right: 0,
                  child: pokemonResourceService.getItemSprite(pokemon.item!, width: Dimens.itemSpriteSize, height: Dimens.itemSpriteSize),
                )
              ],
            ),
          ),
          Expanded(
              flex: dimens.pokemonSheetFlex,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pokemon.ivs != null || pokemon.evs != null) _statsWidget(pokemon.ivs, pokemon.evs, pokemon.nature),
                  SizedBox(height: 8,),
                  moveWidget
                ],
              )
          )
        ],
      ),
    );
  }

  Widget _moveWidget(String moveName) {
    final move = pokemonResourceService.pokemonMoves[moveName];
    Widget moveWidget = Text(moveName, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,);
    if (move == null) {
      return moveWidget;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pokemonResourceService.getTypeSprite(move.type, width: 25.0, height: 25.0),
        SizedBox(width: 8,),
        pokemonResourceService.getCategorySprite(move.category, width: 32.0, height: 32.0),
        SizedBox(width: 8,),
        Flexible(child: Tooltip(message: moveName,child: moveWidget,))
      ],
    );
  }

  Widget _statsWidget(Stats? ivs, Stats? evs, String? nature) {
    return Row(
      children: [
        _statWidget('HP', ivs?.hp, evs?.hp, Natures.neutral),
        _statWidget('Atk', ivs?.attack, evs?.attack, nature != null ? Natures.attackBonus(nature) : Natures.neutral),
        _statWidget('Def', ivs?.defense, evs?.defense, nature != null ? Natures.defenseBonus(nature) : Natures.neutral),
        _statWidget('SpA', ivs?.specialAttack, evs?.specialAttack, nature != null ? Natures.specialAttackBonus(nature) : Natures.neutral),
        _statWidget('SpD', ivs?.specialDefense, evs?.specialDefense, nature != null ? Natures.specialDefenseBonus(nature) : Natures.neutral),
        _statWidget('Spe', ivs?.speed, evs?.speed, nature != null ? Natures.speedBonus(nature) : Natures.neutral),
      ],
    );
  }

  Widget _statWidget(String statName, int? iv, int? ev, int bonus) {
    Color? color;
    switch (bonus) {
      case Natures.bonus:
        color = Colors.deepOrange;
        break;
      case Natures.malus:
        color = Colors.cyan;
        break;
    }
    Widget body = Column(
      children: [
        Text(statName, style: TextStyle(color: color),),
        Text((ev ?? 0).toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text((iv ?? 31).toString(), style: TextStyle(color: color)),
      ],
    );
    if (bonus != Natures.neutral) {
      body = Tooltip(
        message: bonus == Natures.bonus ? "Bonus" : "Malus",
        child: body,
      );
    }
    return Expanded(child: body,);
  }
}