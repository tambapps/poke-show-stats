import 'package:app2/ui/core/widgets.dart';
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets/replay_filters.dart';
import 'usage_stats_viewmodel.dart';

class UsageStatsComponent extends StatefulWidget {
  final UsageStatsViewModel viewModel;
  final bool isMobile;

  const UsageStatsComponent({super.key, required this.viewModel, required this.isMobile});

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

          // TODO use a shared viewModel (or even component?) so that the filters are the same on every screen
          final filtersWidget = ReplayFiltersWidget(viewModel: viewModel.filtersViewModel, applyFilters: (replayPredicate) => viewModel.loadUsages(replayPredicate: replayPredicate), isMobile: dimens.isMobile,);
          return SingleChildScrollView(
            child: Column(children: [
              filtersWidget,
              Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                child: Text("${viewModel.replaysCount} Replays", style: theme.textTheme.titleLarge,),
              ),),
              usageStats(context, localization, dimens, theme)
            ],),
          );
        });
  }

  Widget usageStats(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  Widget _cantDisplay(String text) => Center(
    child: Text(text, textAlign: TextAlign.center,),
  );

  Widget pairUsageCard(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme, String title,
      int Function(MapEntry<Pair<String>, PairStats>, MapEntry<Pair<String>, PairStats>) comparator
      ) {
    final pairStatsMap = viewModel.pairStatsMap;
    final pokepaste = viewModel.pokepaste!;
    final entries = pairStatsMap.entries
      // TODO filter to get only pairs whose both pokemon are in the pokepaste .where((pair) => pokepaste.pokemons.contains(pair.))
      .toList();
    entries.sort(comparator);
    // TODO sort list with a sort parameter
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey,
            width: 2.0
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),
        ...entries.map((entry) => pairUsageCardRow(context, localization, dimens, theme, entry.key, entry.value))
      ],),
    );
  }

  Widget pairUsageCardRow(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Pair<String> pair, PairStats stats) {
    final int winRate = (stats.winCount * 100 / stats.total).truncate();
    return Row(
        mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8.0,),
      viewModel.pokemonResourceService.getPokemonSprite(pair.first),
      viewModel.pokemonResourceService.getPokemonSprite(pair.second),
      SizedBox(width: 75.0, child: Center(child: Text("$winRate%", style: theme.textTheme.titleLarge,),),),
      Text("Won\n${stats.winCount} games out of ${stats.total}", textAlign: TextAlign.center,),
        const SizedBox(width: 8.0,),
      ],);
  }

}

class _DesktopUsageStatsState extends _AbstractUsageStatsState {
  @override
  Widget usageStats(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return pairUsageCard(context, localization, dimens, theme, "Most Common Lead Pairs", (e1, e2) => e2.value.total - e1.value.total);
  }

}

class _MobileUsageStatsState extends _AbstractUsageStatsState {
  @override
  Widget usageStats(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO: implement usageStats
    throw UnimplementedError();
  }
}