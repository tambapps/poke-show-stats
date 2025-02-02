import 'package:app2/ui/core/widgets/tile_card.dart';
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/pokeutils.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets.dart';
import '../../core/widgets/replay_filters.dart';
import 'usage_stats_viewmodel.dart';

class UsageStatsComponent extends StatefulWidget {
  final UsageStatsViewModel viewModel;
  final bool isMobile;
  final ReplayFiltersWidget filtersWidget;

  const UsageStatsComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget});

  @override
  State createState() => isMobile ? _MobileUsageStatsState() : _DesktopUsageStatsState();

}

abstract class _AbstractUsageStatsState extends AbstractViewModelState<UsageStatsComponent> {

  @override
  UsageStatsViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final pokepaste = viewModel.pokepaste;
    if (pokepaste == null) {
      return Center(
        child: Text("Please enter a pokepaste in the Home tab to consult move usages", textAlign: TextAlign.center,),
      );
    }
    return ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return content(context, localization, dimens, theme);
        });
  }
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  
  Widget teraUsageTileCard(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return TileCard(title: "Tera and Win", content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
    viewModel.pokemonUsageStats.entries.map((entry) =>
    _duoUsageCardRow(context, localization, dimens, theme, entry.key, entry.value)).toList(),));
  }

  Widget _duoUsageCardRow(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, String pokemon, UsageStats stats) {
    final int? winRate = stats.teraCount != 0 ? (stats.teraAndWinCount * 100 / stats.teraCount).truncate() : null;
    final teraType = viewModel.pokepaste?.pokemons.where((p) => PokemonNames.pokemonNameMatch(p.name, pokemon)).firstOrNull?.teraType;
    return Row(
      children: [
        const SizedBox(width: 8.0,),
        viewModel.pokemonResourceService.getPokemonSprite(pokemon),
        teraType != null ? viewModel.pokemonResourceService.getTeraTypeSprite(teraType, width: 64.0, height: 64.0) : SizedBox(width: 64.0,),
        ...(winRate != null ?
        [
          Text("Won ${stats.teraAndWinCount} games out of ${stats.teraCount} using tera", textAlign: TextAlign.center,),
          SizedBox(width: 75.0, child: Center(child: Text("$winRate%", style: theme.textTheme.titleLarge, textAlign: TextAlign.center),),),
        ]
            : [Text("Did not tera", textAlign: TextAlign.center,)]),
        const SizedBox(width: 8.0,),
      ],);
  }
}

class _MobileUsageStatsState extends _AbstractUsageStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO: implement content
    throw UnimplementedError();
  }
}

class _DesktopUsageStatsState extends _AbstractUsageStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    const edgePadding = SizedBox(width: 32.0,);
    const padding = SizedBox(width: 64.0,);
    return Column(children: [
      widget.filtersWidget,
      const SizedBox(height: 16.0,),
      Expanded(child:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          edgePadding,
          teraUsageTileCard(context, localization, dimens, theme),
          edgePadding,
        ],)),
      const SizedBox(height: 16.0,),
    ],);
  }
}