import 'package:poke_showstats/data/models/replay.dart';

import '../../../core/widgets.dart';
import '../../../core/widgets/tile_card.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/widgets/replay_filters.dart';
import 'lead_stats_viewmodel.dart';

class LeadStatsComponent extends StatefulWidget {
  final LeadStatsViewModel viewModel;
  final bool isMobile;
  final ReplayFiltersWidget filtersWidget;
  final LeadStats stats;
  final List<Replay> filteredReplays;

  const LeadStatsComponent({super.key, required this.viewModel, required this.isMobile,
    required this.filtersWidget, required this.filteredReplays, required this.stats, });

  @override
  State createState() => isMobile ? _MobileLeadStatsState() : _DesktopLeadStatsState();

}

// could be stateless
abstract class _AbstractLeadStatsState extends AbstractState<LeadStatsComponent> {

  LeadStatsViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return content(context, localization, dimens, theme);
  }

  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

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
      int Function(MapEntry<Duo<String>, WinStats>, MapEntry<Duo<String>, WinStats>) comparator
      ) {
    final entries = widget.stats.duoStatsMap.entries
    /* is it needed?
      .where((entry) =>
        pokepaste.pokemons.any((pokemon) => PokemonNames.pokemonNameMatch(pokemon.name, entry.key.first)) &&
            pokepaste.pokemons.any((pokemon) => PokemonNames.pokemonNameMatch(pokemon.name, entry.key.second)))

     */
      .toList();
    entries.sort(comparator);
    return Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: TileCard(title: title, content: Column(children: entries.map((entry) => _duoUsageCardRow(context, localization, dimens, theme, entry.key.toList(), entry.value)).toList(),)),);
  }

  Widget leadAndWinUsage(BuildContext context, AppLocalization localization, Dimens dimens,
      ThemeData theme) {
    final entries = widget.stats.pokemonStats.entries.toList();
    entries.sort((e1, e2) => e2.value.winCount - e1.value.winCount);
    return Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: TileCard(title: "Lead and Win", content: Column(children: entries.map((entry) => _duoUsageCardRow(context, localization, dimens, theme, [entry.key], entry.value)).toList(),)),);
  }

  Widget _duoUsageCardRow(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<String> pokemons, WinStats stats) {
    final int winRate = (stats.winCount * 100 / stats.total).truncate();
    return Row(
      children: [
        const SizedBox(width: 8.0,),
      ...pokemons.map((pokemon) => viewModel.pokemonResourceService.getPokemonSprite(pokemon)),
        const SizedBox(width: 8.0,),
        Expanded(child: Text("Won\n${stats.winCount} games out of ${stats.total}", textAlign: TextAlign.center,)),
        const SizedBox(width: 8.0,),
        SizedBox(width: 60.0, child: Center(child: Text("$winRate%", style: theme.textTheme.titleLarge, textAlign: TextAlign.center),),),
      ],);
  }
}

class _DesktopLeadStatsState extends _AbstractLeadStatsState {


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
        ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: mostCommonLeadDuo(context, localization, dimens, theme),),
          padding,
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: mostEffectiveLeadDuo(context, localization, dimens, theme),),
        padding,
        ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: leadAndWinUsage(context, localization, dimens, theme),),
        edgePadding,
      ],)),
      const SizedBox(height: 16.0,),
    ],);
  }
}

class _MobileLeadStatsState extends _AbstractLeadStatsState {

  @override
  Widget content(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    const padding = SizedBox(height: 32.0,);
    return SingleChildScrollView(child: Column(children: [
      widget.filtersWidget,
      padding,
      mostCommonLeadDuo(context, localization, dimens, theme),
      padding,
      mostEffectiveLeadDuo(context, localization, dimens, theme),
      padding,
      leadAndWinUsage(context, localization, dimens, theme),
      padding,
    ],),);
  }
}