

import 'package:flutter/material.dart';

import '../../../../data/models/replay.dart';
import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/widgets.dart';
import '../../../core/widgets/replay_filters.dart';
import 'match_by_match_viewmodel.dart';

class MatchByMatchComponent extends StatefulWidget {
  final MatchByMatchViewModel viewModel;
  final bool isMobile;
  // TODO hide selection filters as we don't want to filter one specific game of a BO. OR, display a warning when there is such filter
  final ReplayFiltersWidget filtersWidget;
  final List<Replay> filteredReplays;

  const MatchByMatchComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget, required this.filteredReplays});


  @override
  State createState() => isMobile ? _MobileMatchByMatchComponentState() : _DesktopMatchByMatchComponentState();
}


abstract class _AbstractMatchByMatchComponentState extends AbstractState<MatchByMatchComponent> {

  MatchByMatchViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Text('Coming Soon');
  }
}

class _MobileMatchByMatchComponentState extends _AbstractMatchByMatchComponentState {

}

class _DesktopMatchByMatchComponentState extends _AbstractMatchByMatchComponentState {

}