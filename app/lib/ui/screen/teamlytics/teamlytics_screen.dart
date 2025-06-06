import 'package:poke_showstats/data/models/replay.dart';
import 'package:poke_showstats/ui/screen/teamlytics/matchup_notes/matchup_notes_screen.dart';

import '../../../data/services/pokemon_resource_service.dart';

import '../../core/widgets.dart';
import 'config/home_config_screen.dart';
import 'game_by_game/game_by_game_screen.dart';
import './move_usage/move_usage_screen.dart';
import 'move_usage/move_usage_viewmodel.dart';
import './replay_entries/replay_entries_screen.dart';
import './lead_stats/lead_stats_screen.dart';
import 'lead_stats/lead_stats_viewmodel.dart';
import './usage_stats/usage_stats_screen.dart';
import './usage_stats/usage_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets/replay_filters.dart';
import './teamlytics_viewmodel.dart';

class TeamlyticsScreen extends StatefulWidget {
  const TeamlyticsScreen({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  final TeamlyticsViewModel viewModel;
  final bool isMobile;

  @override
  State<TeamlyticsScreen> createState() => isMobile ? _MobileHomeScreenState() : _DesktopHomeScreenState();
}

abstract class _AbstractHomeScreenState extends AbstractScreenState<TeamlyticsScreen> with TickerProviderStateMixin {

  TeamlyticsViewModel get viewModel => widget.viewModel;
  @override
  PokemonResourceService get pokemonResourceService => viewModel.pokemonResourceService;

  late TabController _tabController;
  late ReplayFiltersViewModel _replayFiltersViewModel;
  late ReplayFilters _filters;

  @override
  void initState() {
    super.initState();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 7, vsync: this);
    // need to reset it as the underline always move to first position when changing screen tab
    _tabController.addListener(() => _replayFiltersViewModel.selectedPokemonFilterIndex.value = 0);
    _filters = ReplayFilters();
    _replayFiltersViewModel = ReplayFiltersViewModel(pokemonResourceService: viewModel.pokemonResourceService, filters: _filters);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filters.dispose();
    super.dispose();
  }

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          body: ListenableBuilder(
              listenable: viewModel.pokemonResourceService,
              builder: (context, _) => body(context, localization, dimens, theme)
          )
      ),
    );
  }

  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  Widget backButton() => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  );

  Widget tabBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, bool isScrollable) {
    return TabBar(
      dividerColor: dimens.isMobile ? Colors.transparent : null,
      controller: _tabController,
      isScrollable: isScrollable,
      tabs: [
        Tab(text: localization.home),
        Tab(text: localization.replayEntries),
        ValueListenableBuilder(valueListenable: viewModel.matchMode,
            builder: (context, matchMode, _) => Tab(text: matchMode ? localization.matchByMatch : localization.gameByGame)),
        Tab(text: localization.moveUsages),
        Tab(text: localization.leadStats),
        Tab(text: localization.usageStats),
        Tab(text: localization.matchUpNotes),
      ],
    );
  }

  Widget tabBarView(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        ListenableBuilder(
            listenable: viewModel.teamlyticChangeNotifier,
            builder: (context, _) => HomeConfigComponent(viewModel: context.read(), isMobile: dimens.isMobile,)),
        ListenableBuilder(
            listenable: viewModel.teamlyticChangeNotifier,
            builder: (context, _) => ReplayEntriesComponent(viewModel: context.read(), replays: viewModel.replays, isMobile: dimens.isMobile,)),
        _tab(dimens, (filtersWidget) => GameByGameComponent(viewModel: context.read(), filtersWidget: filtersWidget, isMobile: dimens.isMobile, filteredReplays: viewModel.filteredReplays,)),
        _tab(dimens, (filtersWidget) => MoveUsageComponent(viewModel: context.read(), filtersWidget: filtersWidget,
            isMobile: dimens.isMobile, pokepaste: viewModel.pokepaste!, pokemonMoveUsageStats: PokemonMoveUsageStats.fromReplays(viewModel.filteredReplays),)),
        _tab(dimens, (filtersWidget) => LeadStatsComponent(viewModel: context.read(), filtersWidget: filtersWidget, isMobile: dimens.isMobile,
          filteredReplays: viewModel.filteredReplays, stats: LeadStats.fromReplays(viewModel.filteredReplays),), preventIfNoPokepaste: true),
        _tab(dimens, (filtersWidget) => UsageStatsComponent(viewModel: context.read(), filtersWidget: filtersWidget, isMobile: dimens.isMobile,
            filteredReplays: viewModel.filteredReplays, pokepaste: viewModel.pokepaste!, pokemonUsageStats: PokemonUsageStats.fromReplays(viewModel.filteredReplays),), preventIfNoPokepaste: true),
        ValueListenableBuilder(
            valueListenable: viewModel.matchUpsNotifiers,
            builder: (context, matchUps, _) => MatchUpNotesComponent(viewModel: context.read(), matchUps: matchUps, isMobile: dimens.isMobile,))
      ],
    );
  }

  Widget _tab(Dimens dimens, Widget Function(ReplayFiltersWidget) tabContentSupplier, {bool preventIfNoPokepaste = false}) {
    return ListenableBuilder(
        listenable: viewModel.teamlyticChangeNotifier,
        builder: (context, _) {
          final replayFiltersWidget = ReplayFiltersWidget(
              viewModel: _replayFiltersViewModel,
              applyFilters: (replayPredicate) => viewModel.replayPredicate = replayPredicate,
              isMobile: dimens.isMobile,
            totalReplaysCount: viewModel.replaysNotifier.value.length,
            matchedReplaysCount: viewModel.filteredReplaysNotifier.value.length,
          );

          if (viewModel.sdNames.isEmpty) {
            return _cantDisplay(replayFiltersWidget, "Please enter your showdown name(s) in the home tab so that I can identify which player you are in replays");
          } else if (viewModel.replays.isEmpty) {
            return _cantDisplay(replayFiltersWidget, "Please enter replays in the Replay Entries tab to consult data");
          } else if (viewModel.replays.every((replay) => replay.gameOutput == GameOutput.UNKNOWN)) {
            return _cantDisplay(replayFiltersWidget, "No showdown name(s) entered matched any of your replays players. Please check them");
          } else if (viewModel.filteredReplaysNotifier.value.isEmpty) {
            return _cantDisplay(replayFiltersWidget, "Applied filters matched 0 replays");
          } else if (viewModel.pokepaste == null && preventIfNoPokepaste) {
            return _cantDisplay(replayFiltersWidget, "Please enter a pokepaste in the Home tab to consult usages");
          } else {
            return tabContentSupplier(replayFiltersWidget);
          }
        });
  }

  Widget _cantDisplay(ReplayFiltersWidget filtersWidget, String text) {
    return SingleChildScrollView(
      child: Column(children: [
        filtersWidget,
        const SizedBox(height: 64.0,),
        Center(
          child: Text(text, textAlign: TextAlign.center,),
        )
      ],),
    );
  }
}

class _MobileHomeScreenState extends _AbstractHomeScreenState {

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Expanded(child: tabBarView(context, localization, dimens, theme)),
      Row(children: [
        backButton(),
        Expanded(child: tabBar(context, localization, dimens, theme, true))
      ],),
    ],);
  }
}

class _DesktopHomeScreenState extends _AbstractHomeScreenState {

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Stack(children: [
        tabBar(context, localization, dimens, theme, false),
        Align(
          alignment: Alignment.centerLeft,
          child: backButton(),)
      ],),
      Expanded(child: tabBarView(context, localization, dimens, theme))
    ],);
  }

}
