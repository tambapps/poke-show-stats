import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';


class HomeConfigComponent extends StatefulWidget {
  final HomeViewModel homeViewModel;
  final HomeConfigViewModel viewModel;

  const HomeConfigComponent({super.key, required this.homeViewModel, required this.viewModel});


  @override
  _HomeConfigComponentState createState() => _HomeConfigComponentState();
}

class _HomeConfigComponentState extends AbstractState<HomeConfigComponent> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final padding = EdgeInsets.symmetric(horizontal: dimens.defaultScreenMargin);
    return ListView(
      children: [
        SizedBox(height: 36,),
        Padding(padding: padding,
          child: Row(
          children: [
            Text(localization.showdownNames, style: theme.textTheme.titleLarge,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            OutlinedButton(
              onPressed: () => widget.viewModel.addSdNameDialog(context, localization),
              child: Text(localization.add,),
            )
          ],
        ),),
        Padding(padding: padding, child: Row(
          children: [
            ...widget.homeViewModel.sdNames.map((sdName) {
              return Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Text("- $sdName"),
                    IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.homeViewModel.removeSdName(sdName))
                  ],));
            })
          ],
        ),),
        SizedBox(height: 32,),
        // pokepaste
        ...pokepasteWidget(localization, theme, padding)
      ],
    );
  }

  List<Widget> pokepasteWidget(AppLocalization localization, ThemeData theme, EdgeInsets padding) {
    final pokepaste = widget.homeViewModel.pokepaste;
    final title = Text(localization.pokepaste, style: theme.textTheme.titleLarge,);
    if (pokepaste == null) {
      return [
        Padding(padding: padding, child: title,),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        Padding(
          padding: padding,
          child: TextField(
            maxLines: null,
            controller: widget.viewModel.pokepasteController,
            onSubmitted: (value) {
              widget.homeViewModel.addSdName(value);
              widget.viewModel.sdNameController.clear();
            },
            decoration: InputDecoration(
              labelText: localization.pasteSomething,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 20,),
        Padding(
            padding: padding,
          child: Align(
            alignment: Alignment.topRight,
            child: OutlinedButton(
              onPressed: () => widget.viewModel.loadPokepaste(),
              child: Text(localization.load,),
            ),
          ),
        )
      ];
    }
    final pokemons = pokepaste.pokemons;
    List<Row> pokemonRows = [];
    int nbRows = (pokemons.length % 3 == 0 ? pokemons.length / 2 : pokemons.length / 2 + 1).toInt();
    for (int row = 0; row < nbRows; row++) {
      List<Widget> rowChildren = [];
      for (int i = row * 3; i < row * 3 + 3 && i < pokemons.length; i++) {
        rowChildren.add(Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: pokemonWidget(pokemons[i]),),));
      }
      pokemonRows.add(Row(children: rowChildren,));
    }
    return [
      Padding(
        padding: padding,
        child: Row(
          children: [
            title,
            SizedBox(width: 16,),
            OutlinedButton(
              onPressed: () => widget.viewModel.removePokepaste(),
              child: Text(localization.change,),
            )
          ],
        ),
      ),
      SizedBox(height: 16,),
      ...pokemonRows
    ];
  }

  Widget pokemonWidget(Pokemon pokemon) {
    StringBuffer buffer = StringBuffer();
    if (pokemon.level != 50) {
      buffer.writeln("Level: ${pokemon.level}");
    }
    if (pokemon.evs != null && !pokemon.evs!.all((stat) => stat == 0)) {
      buffer.writeln("Evs: ${statsString(pokemon.evs!, 0)}");
    }
    buffer.writeln("${pokemon.nature} Nature");
    if (pokemon.ivs != null && !pokemon.ivs!.all((stat) => stat == 31)) {
      buffer.writeln("Ivs: ${statsString(pokemon.ivs!, 31)}");
    }
    for (String move in pokemon.moves) {
      buffer.writeln("- $move");
    }
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(
            flex: 15,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 0.65,
                  child: Tooltip(
                    message: pokemon.name,
                    child: widget.homeViewModel.pokemonImageService.getPokemonArtwork(pokemon.name),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Tooltip(
                    message: pokemon.teraType,
                    child: widget.homeViewModel.pokemonImageService.getTeraTypeSprite(pokemon.teraType, width: Dimens.teraSpriteSize, height: Dimens.teraSpriteSize),
                  ),
                ),
                if (pokemon.item != null) Positioned(
                  bottom: 0,
                  right: 0,
                  child: Tooltip(
                    message: pokemon.item,
                    child: widget.homeViewModel.pokemonImageService.getItemSprite(pokemon.item!, width: Dimens.itemSpriteSize, height: Dimens.itemSpriteSize),
                  ),
                )

              ],
            ),
          ),
          Expanded(flex: 10, child: Text(buffer.toString()))
        ],
      ),
    );
  }

  String statsString(Stats stats, int defaultValue) {
    List<String> statStrings = [];
    if (stats.hp != defaultValue) {
      statStrings.add("${stats.hp} HP");
    }
    if (stats.attack != defaultValue) {
      statStrings.add("${stats.attack} Atk");
    }
    if (stats.defense != defaultValue) {
      statStrings.add("${stats.defense} Def");
    }
    if (stats.specialAttack != defaultValue) {
      statStrings.add("${stats.specialAttack} SpA");
    }
    if (stats.specialDefense != defaultValue) {
      statStrings.add("${stats.specialDefense} SpD");
    }
    if (stats.speed != defaultValue) {
      statStrings.add("${stats.speed} Spe");
    }
    return statStrings.join(" / ");
  }
}