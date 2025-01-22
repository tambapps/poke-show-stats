
import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

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


abstract class _MoveUsageComponentState extends AbstractState<MoveUsageComponent> {
  @override
  MoveUsageViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.loadStats();
  }

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final pokepaste = viewModel.pokepaste;
    if (pokepaste == null) {
      return _cantDisplay("Please enter a pokepaste in the Home tab to consult move usages");
    }
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    final moveUsages = viewModel.pokemonMoveUsages;
    if (moveUsages.isEmpty) {
      return _cantDisplay("Please enter a replays in the Replay Entries tab to consult move usages");
    }
    final filtersViewModel = ReplayFiltersViewModel();
    return SingleChildScrollView(
      child: Column(children: [
        ReplayFiltersWidget(viewModel: filtersViewModel, applyFilters: (replayPredicate) => viewModel.loadStats(replayPredicate: replayPredicate)),
        moveUsagesWidget(pokepaste, moveUsages)
      ],),
    );

  }

  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages);

  Widget _cantDisplay(String text) => Center(
    child: Text(text),
  );
  Widget pokemonMoveUsagesWidget(Map<String, Map<String, int>> moveUsages, Pokemon pokemon) {
    Map<String, int> pokemonMoveUsages = moveUsages[pokemon.name] ?? {};
    final List<PieChartSectionData> sections = [];
    final totalCount = pokemonMoveUsages.isNotEmpty
    ? pokemonMoveUsages.values.reduce((a, b) => a + b).toDouble()
    : 0.0;
    pokemonMoveUsages.forEach((moveName, count) {
      sections.add(PieChartSectionData(
        value: count.toDouble(),
          title: moveName
      ));
    });

    final Widget chartComponent = sections.isNotEmpty ?
    AspectRatio(aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 100,
          centerSpaceRadius: 40,
        ),
      ),)
        : Center(child: Text("No data"),);
    return Row(children: [
      Expanded(flex: 1, child: Container(child: viewModel.pokemonImageService.getPokemonArtwork(pokemon.name),)),
      // TODO display pie chart
      Expanded(flex: 2, child: chartComponent),
    ],);
  }
}

class _MobileMoveUsageComponentState extends _MoveUsageComponentState {

  @override
  Widget moveUsagesWidget(Pokepaste pokepaste, Map<String, Map<String, int>> moveUsages) {
    // TODO: implement moveUsagesWidget
    throw UnimplementedError();
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

