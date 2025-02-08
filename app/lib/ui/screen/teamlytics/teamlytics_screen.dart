
import '../../../data/services/pokemon_resource_service.dart';

import '../../core/widgets.dart';
import 'config/home_config_screen.dart';
import 'config/home_config_viewmodel.dart';
import 'game_by_game/game_by_game_screen.dart';
import './game_by_game/game_by_game_viewmodel.dart';
import './move_usage/move_usage_screen.dart';
import 'move_usage/move_usage_viewmodel.dart';
import './replay_entries/replay_entries_screen.dart';
import 'replay_entries/replay_entries_viewmodel.dart';
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
    viewModel.loadSave();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
    // need to reset it as the underline always move to first position when changing screen tab
    _tabController.addListener(() => _replayFiltersViewModel.selectedPokemonFilterIndex = 0);
    _filters = ReplayFilters();
    _replayFiltersViewModel = ReplayFiltersViewModel(pokemonResourceService: viewModel.pokemonResourceService, filters: _filters);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _replayFiltersViewModel.dispose();
    _filters.dispose();
    super.dispose();
  }

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: appBar(context, localization, dimens, theme),
          body: ListenableBuilder(
              listenable: viewModel.pokemonResourceService,
              builder: (context, _) => body(context, localization, dimens, theme)
          )
      ),
    );
  }

  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  TabBar tabBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, bool isScrollable) {
    return TabBar(
      controller: _tabController,
      isScrollable: isScrollable,
      tabs: [
        Tab(text: localization.home),
        Tab(text: localization.replayEntries),
        Tab(text: localization.gameByGame),
        Tab(text: localization.moveUsages),
        Tab(text: localization.leadStats),
        Tab(text: localization.usageStats),
      ],
    );
  }

  Widget tabBarView(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        ListenableBuilder(
            listenable: viewModel.teamlyticChangeNotifier,
            builder: (context, _) => HomeConfigComponent(viewModel: HomeConfigViewModel(homeViewModel: viewModel, pokepasteParser: context.read()), isMobile: dimens.isMobile,)),
        ListenableBuilder(
            listenable: viewModel.teamlyticChangeNotifier,
            builder: (context, _) => ReplayEntriesComponent(viewModel: ReplayEntriesViewModel(replayParser: context.read(), homeViewModel: viewModel), isMobile: dimens.isMobile,)),
        _tab(dimens, (filtersWidget) => GameByGameComponent(viewModel: GameByGameViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), filtersWidget: filtersWidget, isMobile: dimens.isMobile)),
        _tab(dimens, (filtersWidget) => MoveUsageComponent(viewModel: MoveUsageViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), filtersWidget: filtersWidget, isMobile: dimens.isMobile)),
        _tab(dimens, (filtersWidget) => LeadStatsComponent(viewModel: LeadStatsViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), filtersWidget: filtersWidget, isMobile: dimens.isMobile)),
        _tab(dimens, (filtersWidget) => UsageStatsComponent(viewModel: UsageStatsViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), filtersWidget: filtersWidget, isMobile: dimens.isMobile)),
      ],
    );
  }

  Widget _tab(Dimens dimens, Widget Function(ReplayFiltersWidget) tabContentSupplier) {
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
          if (viewModel.replaysNotifier.value.isEmpty) {
            return _cantDisplay(replayFiltersWidget, "Please enter a replays in the Replay Entries tab to consult move usages");
          } else if (viewModel.filteredReplaysNotifier.value.isEmpty) {
            return _cantDisplay(replayFiltersWidget, "Applied filters matched 0 replays");
          } else {
            return tabContentSupplier(replayFiltersWidget);
          }
        });
  }

  Widget _cantDisplay(ReplayFiltersWidget filtersWidget, String text) {
    return Column(children: [
      filtersWidget,
      Expanded(child: Center(
        child: Text(text, textAlign: TextAlign.center,),
      ))
    ],);
  }
}

class _MobileHomeScreenState extends _AbstractHomeScreenState {

  @override
  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) => null;

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Expanded(child: tabBarView(context, localization, dimens, theme)),
      tabBar(context, localization, dimens, theme, true),
    ],);
  }
}

class _DesktopHomeScreenState extends _AbstractHomeScreenState {
  @override
  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return tabBar(context, localization, dimens, theme, false);
  }

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return tabBarView(context, localization, dimens, theme);
  }

}
