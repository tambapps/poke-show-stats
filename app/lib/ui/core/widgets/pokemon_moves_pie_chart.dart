
import 'package:app2/data/services/pokemon_resource_service.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/utils.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class PokemonMovesPieChart extends StatefulWidget {

  final PokemonMovesPieChartViewModel viewModel;
  const PokemonMovesPieChart({super.key, required this.viewModel});

  @override
  State createState() => _PokemonMovesPieChartState();
}

class _PokemonMovesPieChartState extends AbstractViewModelState<PokemonMovesPieChart> {

  @override
  PokemonMovesPieChartViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
   // final dimens = Dimens.of(context);
    final List<PieChartSectionData> sections = viewModel.getSections(theme);
    final pokemonSpriteWidget = viewModel.getPokemonSprite(100.0);
    if (sections.isEmpty) {
      return Stack(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pokemonSpriteWidget,
            Center(child: Text("No data"),)
          ],
        )
      ],);
    }

    List<Widget> sectionLegends = [];

    for (int i = 0; i < sections.length; i++) {
      String moveName = widget.viewModel.pokemonMoveUsages[i].key;
      sectionLegends.add(Padding(padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(children: [
          Center(child: Container(width: 32.0, height: 32.0, color: sections[i].color,),),
          const SizedBox(width: 16.0,),
          Expanded(child: Tooltip(message: moveName, child: Text(moveName, overflow: TextOverflow.ellipsis,),))
        ]),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(alignment: Alignment.center,
          children: [
          AspectRatio(aspectRatio: dimens.pieChartAspectRatio,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 80,
              ),
            ),),
          Transform.translate(offset: Offset(0, - 15), child: pokemonSpriteWidget,)
        ],),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: sectionLegends.collateBy(2).map((list) => Expanded(child: Column(children: list,))).toList(),)
    ],);
  }
}


class PokemonMovesPieChartViewModel extends ChangeNotifier {

  static final _sectionColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
  final PokemonResourceService pokemonResourceService;
  final String pokemonName;
  final List<MapEntry<String, int>> pokemonMoveUsages;

  PokemonMovesPieChartViewModel({
    required this.pokemonResourceService,
    required this.pokemonName,
    required Map<String, int> pokemonMoveUsages}): pokemonMoveUsages = pokemonMoveUsages.entries.toList() {
    this.pokemonMoveUsages.sort((e1, e2) =>  e2.value - e1.value);
  }

  Widget getPokemonSprite(double size) => pokemonResourceService.getPokemonSprite(pokemonName, width: size, height: size);

  List<PieChartSectionData> getSections(ThemeData theme) {
    if (pokemonMoveUsages.isEmpty) {
      return [];
    }
    final List<PieChartSectionData> sections = [];

    final total = pokemonMoveUsages.map((e) => e.value.toDouble())
        .reduce((a, b) => a + b);
    for(int i = 0; i < pokemonMoveUsages.length; i++) {
      final entry = pokemonMoveUsages[i];
      sections.add(PieChartSectionData(
          value: entry.value.toDouble(),
          title: "${(entry.value / total * 100.0).toStringAsFixed(2)}%",
          titleStyle: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          color: _sectionColors[i]
      ));
    }
    return sections;
  }
}