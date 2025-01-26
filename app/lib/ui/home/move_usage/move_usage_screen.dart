
import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/widgets/pokemon_moves_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../core/widgets/replay_filters.dart';
import 'move_usage_viewmodel.dart';

class MoveUsageComponent extends StatefulWidget {
  final MoveUsageViewModel viewModel;
  final bool isMobile;

  const MoveUsageComponent({super.key, required this.viewModel, required this.isMobile});

  @override
  _MoveUsageComponentState createState() => isMobile ? _MobileMoveUsageComponentState() : _DesktopMoveUsageComponentState();
}


abstract class _MoveUsageComponentState extends AbstractViewModelState<MoveUsageComponent> {
  @override
  MoveUsageViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final pokepaste = viewModel.pokepaste;
    if (pokepaste == null) {
      return _cantDisplay("Please enter a pokepaste in the Home tab to consult move usages");
    }
    return ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!viewModel.hasReplays) {
            return _cantDisplay("Please enter a replays in the Replay Entries tab to consult move usages");
          }
          final moveUsages = viewModel.pokemonMoveUsages;

          final filtersWidget = ReplayFiltersWidget(viewModel: viewModel.filtersViewModel, applyFilters: (replayPredicate) => viewModel.loadStats(replayPredicate: replayPredicate), isMobile: dimens.isMobile,);
          if (viewModel.replaysCount == 0) {
            return Column(children: [
              filtersWidget,
              moveUsages.isNotEmpty ? moveUsagesWidget(pokepaste, moveUsages)
                  : Expanded(child: _cantDisplay("Applied filters matched 0 replays"))
            ],);
          }
          return SingleChildScrollView(
            child: Column(children: [
              filtersWidget,

                Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                  child: Text("${viewModel.replaysCount} Replays", style: theme.textTheme.titleLarge,),
                ),),
              moveUsagesWidget(pokepaste, moveUsages),
              SizedBox(height: 32.0,)
            ],),
          );
        });
  }

  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages);

  Widget _cantDisplay(String text) => Center(
    child: Text(text, textAlign: TextAlign.center,),
  );

  Widget pokemonMoveUsagesWidget(Map<String, Map<String, int>> moveUsages, Pokemon pokemon) {
    Map<String, int> pokemonMoveUsages = moveUsages[pokemon.name] ?? {};
    final viewModel = PokemonMovesPieChartViewModel(pokemonResourceService: context.read(), pokemonName: pokemon.name, pokemonMoveUsages: pokemonMoveUsages);
    return PokemonMovesPieChart(viewModel: viewModel);
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

