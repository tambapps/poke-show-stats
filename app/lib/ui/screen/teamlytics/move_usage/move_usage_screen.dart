import 'package:pokemon_core/pokemon_core.dart';

import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/widgets/pokemon_moves_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../core/widgets.dart';
import '../../../core/widgets/replay_filters.dart';
import 'move_usage_viewmodel.dart';

class MoveUsageComponent extends StatefulWidget {
  final MoveUsageViewModel viewModel;
  final bool isMobile;
  final ReplayFiltersWidget filtersWidget;
  final Pokepaste pokepaste;
  final PokemonMoveUsageStats pokemonMoveUsageStats;

  const MoveUsageComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget, required this.pokepaste, required this.pokemonMoveUsageStats});

  @override
  _MoveUsageComponentState createState() => isMobile ? _MobileMoveUsageComponentState() : _DesktopMoveUsageComponentState();
}


// could be a stateless widdget
abstract class _MoveUsageComponentState extends AbstractState<MoveUsageComponent> {

  MoveUsageViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(children: [
        widget.filtersWidget,
        moveUsagesWidget(widget.pokepaste, widget.pokemonMoveUsageStats.usages),
        const SizedBox(height: 32.0,)
      ],),
    );
  }

  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages);

  Widget pokemonMoveUsagesWidget(Map<String, Map<String, int>> moveUsages, Pokemon pokemon) {
    Map<String, int> pokemonMoveUsages = moveUsages[Pokemon.normalizeToBase(pokemon.name)] ?? {};
    return PokemonMovesPieChart(pokemonName: pokemon.name, moveUsages: pokemonMoveUsages);
  }
}

class _MobileMoveUsageComponentState extends _MoveUsageComponentState {

  @override
  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages) {
    return Column(
      children: pokepaste.pokemons.map((pokemon) => Padding(padding: EdgeInsets.symmetric(horizontal: 32),
        child: pokemonMoveUsagesWidget(moveUsages, pokemon),)).toList()
      ,);
  }
  
}

class _DesktopMoveUsageComponentState extends _MoveUsageComponentState {

  @override
  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages) {
    final pokemons = pokepaste.pokemons;
    List<Row> pokemonRows = [];
    int nbRows = (pokemons.length % 3 == 0 ? pokemons.length / 2 : pokemons.length / 2 + 1).toInt();
    for (int row = 0; row < nbRows; row++) {
      List<Widget> rowChildren = [];
      for (int i = row * 3; i < row * 3 + 3 && i < pokemons.length; i++) {
        final pokemon = pokemons[i];
        rowChildren.add(Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: pokemonMoveUsagesWidget(moveUsages, pokemon),),));
      }
      pokemonRows.add(Row(children: rowChildren,));
    }
    return Column(children: pokemonRows,);
  }

}

