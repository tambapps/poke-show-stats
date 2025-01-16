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
  });

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractState<HomeScreen> {

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
            appBar: TabBar(
              onTap: (index) => widget.viewModel.onTabSelected(index),
              tabs: [
                Tab(text: localization.home),
                Tab(text: localization.replayEntries),
                Tab(text: localization.gameByGame),
              ],
            ),
            body: TabBarView(
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
            )
        ),
      ),
    );
  }
}