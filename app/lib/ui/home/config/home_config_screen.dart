import 'package:app2/ui/core/pokeutils.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';


class HomeConfigComponent extends StatefulWidget {
  final HomeConfigViewModel viewModel;
  final bool isMobile;

  const HomeConfigComponent({super.key, required this.viewModel, required this.isMobile});


  @override
  _HomeConfigComponentState createState() => isMobile ? _MobileHomeConfigComponentState() : _DesktopHomeConfigComponentState();
}

abstract class _HomeConfigComponentState extends AbstractViewModelState<HomeConfigComponent> {

  late TextEditingController _pokepasteController;

  @override
  HomeConfigViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final padding = EdgeInsets.symmetric(horizontal: dimens.defaultScreenMargin);
    return ListView(
      children: [
        SizedBox(height: dimens.homeConfigScreenTopPadding,),
        Padding(padding: padding,
          child: Row(
          children: [
            Text(localization.showdownNames, style: theme.textTheme.titleLarge,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            OutlinedButton(
              onPressed: () => viewModel.addSdNameDialog(context, localization),
              child: Text(localization.add,),
            )
          ],
        ),),
        Padding(
          padding: padding,
          child: GridView.builder(
              shrinkWrap: true, // Makes the GridView wrap its content
              itemCount: viewModel.sdNames.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: dimens.sdNamesMaxCrossAxisExtent, // Maximum width of each grid item
                mainAxisSpacing: 10, // Spacing between rows
                crossAxisSpacing: 10, // Spacing between columns
                childAspectRatio: 4, // Aspect ratio of each grid item
              ),
              itemBuilder: (context, index) {
                final sdName = viewModel.sdNames[index];
                return Row(children: [
                  Container(constraints: BoxConstraints(maxWidth: dimens.sdNameMaxWidth), child: Tooltip(message: sdName, child: Text(sdName, overflow: TextOverflow.ellipsis,),),),
                  IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => viewModel.removeSdName(sdName))
                ],);
              }
          ),),
        SizedBox(height: 32,),
        // pokepaste
        ...pokepaste(localization, dimens, theme, padding)
      ],
    );
  }

  List<Widget> pokepasteWidget(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste);

  List<Widget> pokepaste(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding) {
    final pokepaste = viewModel.pokepaste;
    final title = Text(localization.pokepaste, style: theme.textTheme.titleLarge,);
    if (pokepaste == null) {
      return pokepasteForm(localization, theme, padding, title);
    } else {
      return pokepasteWidget(localization, dimens, theme, padding, title, pokepaste);
    }
  }

  List<Widget> pokepasteForm(AppLocalization localization, ThemeData theme, EdgeInsets padding, Widget title) {
    return [
      Padding(padding: padding, child: title,),
      Padding(padding: EdgeInsets.symmetric(vertical: 8)),
      Padding(
        padding: padding,
        child: TextField(
          maxLines: null,
          controller: _pokepasteController,
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
            onPressed: () => viewModel.loadPokepaste(_pokepasteController),
            child: Text(localization.load,),
          ),
        ),
      )
    ];
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
                  child: viewModel.pokemonResourceService.getPokemonArtwork(pokemon.name),
                ),
                Positioned(
                  top: dimens.pokepastePokemonIconsOffset,
                  left: 0,
                  child: viewModel.pokemonResourceService.getTeraTypeSprite(pokemon.teraType, width: Dimens.teraSpriteSize, height: Dimens.teraSpriteSize),
                ),
                if (pokemon.item != null) Positioned(
                  bottom: dimens.pokepastePokemonIconsOffset,
                  right: 0,
                  child: viewModel.pokemonResourceService.getItemSprite(pokemon.item!, width: Dimens.itemSpriteSize, height: Dimens.itemSpriteSize),
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

  Widget _moveWidget(String moveName) {
    final move = viewModel.pokemonMoves[moveName];
    Widget moveWidget = Text(moveName, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,);
    if (move == null) {
      return moveWidget;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        viewModel.pokemonResourceService.getTypeSprite(move.type, width: 25.0, height: 25.0),
        SizedBox(width: 8,),
        viewModel.pokemonResourceService.getCategorySprite(move.category, width: 32.0, height: 32.0),
        SizedBox(width: 8,),
        Flexible(child: Tooltip(message: moveName,child: moveWidget,))
      ],
    );
  }


  @override
  void initState() {
    _pokepasteController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pokepasteController.dispose();
    super.dispose();
  }
}

class _MobileHomeConfigComponentState extends _HomeConfigComponentState {

  @override
  List<Widget> pokepasteWidget(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste) {
    return [
      Row(
        children: [
          title,
          SizedBox(width: 16,),
          OutlinedButton(
            onPressed: () => viewModel.removePokepaste(),
            child: Text(localization.change,),
          )
        ],
      ),
      Padding(
        padding: padding,
        child: Column(
          children: pokepaste.pokemons.map((pokemon) => pokemonWidget(dimens, pokemon)).toList(),
        ),
      ),
    ];

  }
}

class _DesktopHomeConfigComponentState extends _HomeConfigComponentState {

  @override
  List<Widget> pokepasteWidget(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste) {
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
    return [
      Padding(
        padding: padding,
        child: Row(
          children: [
            title,
            SizedBox(width: 16,),
            OutlinedButton(
              onPressed: () => viewModel.removePokepaste(),
              child: Text(localization.change,),
            )
          ],
        ),
      ),
      SizedBox(height: 16,),
      ...pokemonRows
    ];
  }

}