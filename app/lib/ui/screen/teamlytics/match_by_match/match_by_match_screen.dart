

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
  final ReplayFiltersWidget filtersWidget;
  final List<Replay> filteredReplays;

  const MatchByMatchComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget, required this.filteredReplays});


  @override
  State createState() => isMobile ? _MobileMatchByMatchComponentState() : _DesktopMatchByMatchComponentState();
}


abstract class _AbstractMatchByMatchComponentState extends AbstractState<MatchByMatchComponent> {

  MatchByMatchViewModel get viewModel => widget.viewModel;

  // TODO hide selection filters as we don't want to filter one specific game of a BO. OR, display a warning when there is such filter

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {

    final double? gameWinRateRatio = widget.filteredReplays.isEmpty ? null
        : widget.filteredReplays.where((replay) => replay.gameOutput == GameOutput.WIN).length.toDouble() / widget.filteredReplays.length.toDouble();
    final matches = viewModel.filteredMatches;
    final double? matchWinRateRatio = matches.isNotEmpty ? _countWins(matches) / matches.length.toDouble() : null;

    final textStyle = theme.textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 8.0, bottom: 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gameWinRateRatio != null)
            Text("Per Game Win Rate: ${(gameWinRateRatio * 100).toStringAsFixed(1)}%", style: textStyle),
          if (matchWinRateRatio != null)
            Text("Per Match Win Rate: ${(matchWinRateRatio * 100).toStringAsFixed(1)}%", style: textStyle),
        ],
      ),
    );
  }

  double _countWins(List<List<Replay>> matches) {
    return matches.where((replays) {
      // TODO verify logic
      final wins = replays.where((replay) => replay.gameOutput == GameOutput.WIN).length;
      return wins > replays.length / 2;
    }).length.toDouble();
  }
}

class _MobileMatchByMatchComponentState extends _AbstractMatchByMatchComponentState {

}

class _DesktopMatchByMatchComponentState extends _AbstractMatchByMatchComponentState {

}