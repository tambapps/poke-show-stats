import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_screen.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_screen.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_viewmodel.dart';
import 'package:app2/ui/home/move_usage/move_usage_screen.dart';
import 'package:app2/ui/home/move_usage/move_usage_viewmodel.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_screen.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_viewmodel.dart';
import 'package:app2/ui/home/lead_stats/lead_stats_screen.dart';
import 'package:app2/ui/home/lead_stats/lead_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/applocalization.dart';
import '../core/themes/dimens.dart';
import '../core/widgets/replay_filters.dart';
import 'home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  final HomeViewModel viewModel;
  final bool isMobile;

  @override
  State<HomeScreen> createState() => isMobile ? _MobileHomeScreenState() : _DesktopHomeScreenState();
}

abstract class _AbstractHomeScreenState extends AbstractViewModelState<HomeScreen> with TickerProviderStateMixin {

  @override
  HomeViewModel get viewModel => widget.viewModel;
  late TabController _tabController;
  late ReplayFiltersViewModel _replayFiltersViewModel;
  late ReplayFilters _filters;

  @override
  void initState() {
    super.initState();
    viewModel.loadSave();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
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
    return Padding(
      padding: EdgeInsets.only(top: dimens.screenBoundsTopMargin),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: appBar(context, localization, dimens, theme),
            body: ListenableBuilder(
                listenable: viewModel.pokemonResourceService,
                builder: (context, _) => body(context, localization, dimens, theme)
            )
        ),
      ),
    );
  }

  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  TabBar tabBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, bool isScrollable) {
    return TabBar(
      controller: _tabController,
      isScrollable: isScrollable,
      onTap: (index) => viewModel.onTabSelected(index),
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
            listenable: viewModel,
            builder: (context, _) => HomeConfigComponent(viewModel: HomeConfigViewModel(homeViewModel: viewModel, pokepasteParser: context.read()), isMobile: dimens.isMobile,)),
        ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => ReplayEntriesComponent(viewModel: ReplayEntriesViewModel(replayParser: context.read(), homeViewModel: viewModel), isMobile: dimens.isMobile,)),
        _tab(dimens, () => GameByGameComponent(viewModel: GameByGameViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), isMobile: dimens.isMobile)),
        _tab(dimens, () => MoveUsageComponent(viewModel: MoveUsageViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), isMobile: dimens.isMobile)),
        _tab(dimens, () => LeadStatsComponent(viewModel: LeadStatsViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), isMobile: dimens.isMobile)),
        ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => Center(child: Text('TODO'),))
      ],
    );
  }

  Widget _tab(Dimens dimens, Widget Function() tabComponent) {
    return ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final replayFiltersWidget = ReplayFiltersWidget(
              viewModel: _replayFiltersViewModel,
              applyFilters: (replayPredicate) => viewModel.replayPredicate = replayPredicate,
              isMobile: dimens.isMobile,
            totalReplaysCount: viewModel.replays.length,
            matchedReplaysCount: viewModel.filteredReplays.length,
          );
          return Column(children: [
            replayFiltersWidget,
            Expanded(child: _tabContent(tabComponent))
          ],);
        });
  }

  Widget _tabContent(Widget Function() tabComponent) {
    if (viewModel.replays.isEmpty) {
      return Center(
        child: Text("Please enter a replays in the Replay Entries tab to consult move usages", textAlign: TextAlign.center,),
      );
    } else if (viewModel.filteredReplays.isEmpty) {
      return Center(
        child: Text("Applied filters matched 0 replays", textAlign: TextAlign.center,),
      );
    } else {
      return tabComponent();
    }
  }
}

class _MobileHomeScreenState extends _AbstractHomeScreenState {

  @override
  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) => null;

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final double navigationBarHeight = MediaQuery.of(context).viewPadding.bottom;
    return Column(children: [
      Expanded(child: tabBarView(context, localization, dimens, theme)),
      tabBar(context, localization, dimens, theme, true),
      SizedBox(height: navigationBarHeight,)
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
