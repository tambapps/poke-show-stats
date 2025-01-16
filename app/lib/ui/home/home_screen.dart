import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_screen.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_screen.dart';
import 'package:app2/ui/home/game_by_game/game_by_game_viewmodel.dart';
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

abstract class _AbstractHomeScreenState extends AbstractState<HomeScreen> {

  @override
  void initState() {
    widget.viewModel.loadSave();
    super.initState();
  }
  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: dimens.screenBoundsTopMargin),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: appBar(context, localization, dimens, theme),
            body: body(context, localization, dimens, theme)
        ),
      ),
    );
  }

  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  Widget tabBarView(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return TabBarView(
      children: [
        ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => HomeConfigComponent(viewModel: HomeConfigViewModel(homeViewModel: widget.viewModel, pokepasteParser: context.read()), isMobile: dimens.isMobile,)),
        ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => ReplayEntriesComponent(viewModel: ReplayEntriesViewModel(replayParser: context.read(), homeViewModel: widget.viewModel),)),
        ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => GameByGameComponent(viewModel: GameByGameViewModel(homeViewModel: widget.viewModel, pokemonImageService: context.read()), isMobile: dimens.isMobile)),
      ],
    );
  }

  TabBar tabBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, bool isScrollable) {
    return TabBar(
      isScrollable: isScrollable,
      onTap: (index) => widget.viewModel.onTabSelected(index),
      tabs: [
        Tab(text: localization.home),
        Tab(text: localization.replayEntries),
        Tab(text: localization.gameByGame),
      ],
    );
  }
}

class _MobileHomeScreenState extends _AbstractHomeScreenState {

  @override
  PreferredSizeWidget? appBar(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) => null;

  @override
  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Expanded(child: tabBarView(context, localization, dimens, theme)),
      tabBar(context, localization, dimens, theme, true)
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