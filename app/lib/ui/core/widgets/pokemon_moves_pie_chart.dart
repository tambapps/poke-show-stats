import 'package:provider/provider.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class PokemonMovesPieChart extends AbstractStatelessWidget {
  static final _sectionColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.cyanAccent];

  final Map<String, int> moveUsages;
  final String pokemonName;

  const PokemonMovesPieChart({super.key, required this.moveUsages, required this.pokemonName});

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final List<MapEntry<String, int>> moveUsagesList = moveUsages.entries.toList();
    moveUsagesList.sort((e1, e2) =>  e2.value - e1.value);

    final PokemonResourceService pokemonResourceService = context.read();
    final List<PieChartSectionData> sections = _getSections(moveUsagesList, theme);
    final pokemonSpriteWidget = pokemonResourceService.getPokemonSprite(pokemonName, width: 100.0, height: 100.0);;
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
        _legendWidget(moveUsagesList, sections)
    ],);
  }

  Widget _legendWidget(List<MapEntry<String, int>> moveUsagesList, List<PieChartSectionData> sections) {
    List<Widget> sectionLegends = [];

    for (int i = 0; i < moveUsagesList.length; i++) {
      String moveName = moveUsagesList[i].key;
      sectionLegends.add(Padding(padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(children: [
          Center(child: Container(width: 32.0, height: 32.0, color: sections[i].color,),),
          const SizedBox(width: 16.0,),
          Expanded(child: Tooltip(message: moveName, child: Text(moveName, overflow: TextOverflow.ellipsis,),))
        ]),
      ));
    }
    return         Row(
      mainAxisSize: MainAxisSize.min,
      children: sectionLegends.collateBy(2).map((list) => Expanded(child: Column(children: list,))).toList(),);
  }

  List<PieChartSectionData> _getSections(List<MapEntry<String, int>> pokemonMoveUsages, ThemeData theme) {
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
          color: i < _sectionColors.length ? _sectionColors[i] : Colors.black
      ));
    }
    return sections;
  }
}