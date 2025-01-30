import 'package:app2/ui/core/widgets.dart';
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets/replay_filters.dart';
import 'lead_stats_viewmodel.dart';

class LeadStatsComponent extends StatefulWidget {
  final LeadStatsViewModel viewModel;
  final bool isMobile;

  const LeadStatsComponent({super.key, required this.viewModel, required this.isMobile});

  @override
  State createState() => isMobile ? _MobileLeadStatsState() : _DesktopLeadStatsState();

}

abstract class _AbstractLeadStatsState extends AbstractViewModelState<LeadStatsComponent> {

  @override
  LeadStatsViewModel get viewModel => widget.viewModel;

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
          final filtersWidget = Column(children: [
            ReplayFiltersWidget(viewModel: viewModel.filtersViewModel, applyFilters: (replayPredicate) => viewModel.loadUsages(replayPredicate: replayPredicate), isMobile: dimens.isMobile,),
            Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.only(left: 32.0, top: 8.0),
              child: Text("${viewModel.replaysCount} Replays", style: theme.textTheme.titleLarge,),
            ),)
          ],);
          return content(context, localization, dimens, theme, filtersWidget);
        });
  }

  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Widget filtersWidget);

  Widget _cantDisplay(String text) => Center(
    child: Text(text, textAlign: TextAlign.center,),
  );

  Widget mostCommonLeadDuo(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme) {
    return _duoUsageCard(context, localization, dimens, theme, "Most Common Lead Duo", (e1, e2) => e2.value.total.compareTo(e1.value.total));
  }

  Widget mostEffectiveLeadDuo(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme) {
    return _duoUsageCard(context, localization, dimens, theme, "Most Effective Lead Duo", (e1, e2) => e2.value.winRate.compareTo(e1.value.winRate));
  }

  Widget _duoUsageCard(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme, String title,
      int Function(MapEntry<Duo<String>, LeadStats>, MapEntry<Duo<String>, LeadStats>) comparator
      ) {
    final entries = viewModel.duoStatsMap.entries
    /* is it needed?
      .where((entry) =>
        pokepaste.pokemons.any((pokemon) => PokemonNames.pokemonNameMatch(pokemon.name, entry.key.first)) &&
            pokepaste.pokemons.any((pokemon) => PokemonNames.pokemonNameMatch(pokemon.name, entry.key.second)))

     */
      .toList();
    entries.sort(comparator);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey,
            width: 2.0
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: duoUsageCardContent(
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),
          entries.map((entry) => _duoUsageCardRow(context, localization, dimens, theme, entry.key.toList(), entry.value))
      ),
    );
  }

  Widget leadAndWinUsage(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme) {
    final entries = viewModel.pokemonStats.entries.toList();
    entries.sort((e1, e2) => e2.value.winCount - e1.value.winCount);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey,
            width: 2.0
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: duoUsageCardContent(
          Text("Lead and Win", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),
          entries.map((entry) => _duoUsageCardRow(context, localization, dimens, theme, [entry.key], entry.value)),
      ),
    );
  }

  Widget duoUsageCardContent(Widget title, Iterable<Widget> entries);

  Widget _duoUsageCardRow(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<String> pokemons, LeadStats stats) {
    final int winRate = (stats.winCount * 100 / stats.total).truncate();
    return Row(
        mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8.0,),
      ...pokemons.map((pokemon) => viewModel.pokemonResourceService.getPokemonSprite(pokemon)),
      SizedBox(width: 75.0, child: Center(child: Text("$winRate%", style: theme.textTheme.titleLarge,),),),
      Text("Won\n${stats.winCount} games out of ${stats.total}", textAlign: TextAlign.center,),
        const SizedBox(width: 8.0,),
      ],);
  }
}

class _DesktopLeadStatsState extends _AbstractLeadStatsState {


  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Widget filtersWidget) {
    const edgePadding = SizedBox(width: 32.0,);
    const padding = SizedBox(width: 64.0,);
    return Column(children: [
      filtersWidget,
      const SizedBox(height: 16.0,),
      Expanded(child:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        edgePadding,
        mostCommonLeadDuo(context, localization, dimens, theme),
        padding,
        mostEffectiveLeadDuo(context, localization, dimens, theme),
        padding,
        leadAndWinUsage(context, localization, dimens, theme),
        edgePadding,
      ],)),
      const SizedBox(height: 16.0,),
    ],);
  }

  @override
  Widget duoUsageCardContent(Widget title, Iterable<Widget> entries) {
    return Column(children: [
      title,
      Expanded(child: SingleChildScrollView(child: Column(children: [...entries, const SizedBox(height: 8.0,)],),))
    ],);
  }
}

class _MobileLeadStatsState extends _AbstractLeadStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Widget filtersWidget) {
    const padding = SizedBox(height: 32.0,);
    return SingleChildScrollView(child: Column(children: [
      filtersWidget,
      padding,
      mostCommonLeadDuo(context, localization, dimens, theme),
      padding,
      mostEffectiveLeadDuo(context, localization, dimens, theme),
      padding,
      leadAndWinUsage(context, localization, dimens, theme),
      padding,
    ],),);
  }

  @override
  Widget duoUsageCardContent(Widget title, Iterable<Widget> entries) {
    return ExpansionTile(
      title: title,
      children: [...entries, const SizedBox(height: 8.0,)],
    );
  }
}