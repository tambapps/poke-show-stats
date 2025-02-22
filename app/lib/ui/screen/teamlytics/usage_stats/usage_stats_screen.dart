import 'package:pokemon_core/pokemon_core.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../../data/models/replay.dart';
import '../../../core/widgets/tile_card.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/widgets.dart';
import '../../../core/widgets/replay_filters.dart';
import 'usage_stats_viewmodel.dart';

class UsageStatsComponent extends StatefulWidget {
  final UsageStatsViewModel viewModel;
  final bool isMobile;
  final ReplayFiltersWidget filtersWidget;
  final List<Replay> filteredReplays;
  final Pokepaste pokepaste;
  final PokemonUsageStats pokemonUsageStats;

  const UsageStatsComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget, required this.filteredReplays, required this.pokepaste, required this.pokemonUsageStats});

  @override
  State createState() => isMobile ? _MobileUsageStatsState() : _DesktopUsageStatsState();

}

// could be stateless
abstract class _AbstractUsageStatsState extends AbstractState<UsageStatsComponent> {

  UsageStatsViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return content(context, localization, dimens, theme);
  }

  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  Widget teraUsageTileCard(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return _usageTileCard(context, localization, dimens, theme,
        "Tera and Win",
        "Win rate of each pokemon amongst all games it did terastalize",
            (pokemon, stats) {
          final int? winRate = stats.teraCount != 0 ? (stats.teraAndWinCount * 100 / stats.teraCount).truncate() : null;
          String text = winRate != null ? "Won\n${stats.teraAndWinCount} out of ${stats.teraCount} games" : "Did not tera";
          return _usageCardRow(context, localization, dimens, theme, pokemon, text, winRate, true);
        });
  }

  Widget usageTileCard(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return _usageTileCard(context, localization, dimens, theme,
        "Usage and Win",
        "Win rate of each pokemon amongst all games it did participate",
            (pokemon, stats) {
          final int winRate = (stats.winCount * 100 / stats.total).truncate();
          String text = "Won\n${stats.winCount} out of ${stats.total} games";
          return _usageCardRow(context, localization, dimens, theme, pokemon, text, winRate, false);
        });
  }

  Widget globalUsageTileCard(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return _usageTileCard(context, localization, dimens, theme,
        "Usage",
        "Rate at which each pokemon was selected to participate in a game",
            (pokemon, stats) {
          final int winRate = (stats.total * 100 / widget.filteredReplays.length).truncate();
          String text = "Participated in\n${stats.total} out of ${widget.filteredReplays.length} games";
          return _usageCardRow(context, localization, dimens, theme, pokemon, text, winRate, false);
        });
  }

  Widget _usageTileCard(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme,
      String title, String tooltip,
      Widget Function(String, UsageStats) rowGenerator) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: TileCard(title: title, tooltip: tooltip, content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      widget.pokemonUsageStats.usages.entries.map((entry) => rowGenerator(entry.key, entry.value)).toList(),)),);
  }

  Widget _usageCardRow(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, String pokemon, String text, int? winRate, bool displayTera) {
    final teraType = widget.pokepaste.pokemons.where((p) => Pokemon.nameMatch(p.name, pokemon)).firstOrNull?.teraType;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8.0,),
        viewModel.pokemonResourceService.getPokemonSprite(pokemon),
        if (displayTera) teraType != null ? viewModel.pokemonResourceService.getTeraTypeSprite(teraType, width: 64.0, height: 64.0) : SizedBox(width: 64.0,),
        Expanded(child: Text(text, textAlign: TextAlign.center,)),
        SizedBox(width: 60.0, child: Center(child: Text(winRate != null ? "$winRate%" : "", style: theme.textTheme.titleLarge),),),
        const SizedBox(width: 8.0,),
      ],);
  }
}

class _MobileUsageStatsState extends _AbstractUsageStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    const padding = SizedBox(height: 32.0,);
    return SingleChildScrollView(child: Column(children: [
      widget.filtersWidget,
      padding,
      teraUsageTileCard(context, localization, dimens, theme),
      padding,
      usageTileCard(context, localization, dimens, theme),
      padding,
      globalUsageTileCard(context, localization, dimens, theme),
      padding,
    ],),);
  }
}

class _DesktopUsageStatsState extends _AbstractUsageStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    const edgePadding = SizedBox(width: 32.0,);
    const padding = SizedBox(width: 64.0,);
    double screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth / 4;
    return Column(children: [
      widget.filtersWidget,
      const SizedBox(height: 16.0,),
      Expanded(child:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          edgePadding,
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: teraUsageTileCard(context, localization, dimens, theme),),
          padding,
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: usageTileCard(context, localization, dimens, theme),),
          padding,
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: globalUsageTileCard(context, localization, dimens, theme),),
          edgePadding,
        ],)),
      const SizedBox(height: 16.0,),
    ],);
  }
}