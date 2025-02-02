import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets.dart';
import 'usage_stats_viewmodel.dart';

class UsageStatsComponent extends StatefulWidget {
  final UsageStatsViewModel viewModel;
  final bool isMobile;

  const UsageStatsComponent({super.key, required this.viewModel, required this.isMobile});

  @override
  State createState() => isMobile ? _MobileUsageStatsState() : _DesktopUsageStatsState();

}

abstract class _AbstractUsageStatsState extends AbstractViewModelState<UsageStatsComponent> {

  @override
  UsageStatsViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO: implement doBuild
    throw UnimplementedError();
  }
}

class _MobileUsageStatsState extends _AbstractUsageStatsState {

}

class _DesktopUsageStatsState extends _AbstractUsageStatsState {

}