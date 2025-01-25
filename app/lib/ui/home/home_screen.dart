import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_screen.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_screen.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_viewmodel.dart';
import 'package:app2/ui/home/move_usage/move_usage_screen.dart';
import 'package:app2/ui/home/move_usage/move_usage_viewmodel.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_screen.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/applocalization.dart';
import '../core/themes/dimens.dart';
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

  @override
  void initState() {
    super.initState();
    viewModel.loadSave();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => GameByGameComponent(viewModel: GameByGameViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), isMobile: dimens.isMobile)),
        ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => MoveUsageComponent(viewModel: MoveUsageViewModel(homeViewModel: viewModel, pokemonResourceService: context.read()), isMobile: dimens.isMobile)),
      ],
    );
  }

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
      ],
    );
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