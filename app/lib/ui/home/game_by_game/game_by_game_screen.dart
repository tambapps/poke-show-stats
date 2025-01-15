
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets.dart';
import 'game_by_game_viewmodel.dart';

class GameByGameComponent extends StatefulWidget {
  final GameByGameViewModel viewModel;

  const GameByGameComponent({super.key, required this.viewModel});


  @override
  _GameByGameComponentState createState() => _GameByGameComponentState();
}

class _GameByGameComponentState extends AbstractState<GameByGameComponent> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Center(child: Text("Content for Tab 3"));
  }
}