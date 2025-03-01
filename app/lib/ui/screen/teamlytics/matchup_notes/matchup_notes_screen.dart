import 'package:flutter/material.dart';
import 'package:poke_showstats/data/models/matchup.dart';
import 'package:poke_showstats/ui/core/localization/applocalization.dart';
import 'package:poke_showstats/ui/core/themes/dimens.dart';
import 'package:poke_showstats/ui/screen/teamlytics/matchup_notes/matchup_notes_viewmodel.dart';

import '../../../core/widgets.dart';

class MatchUpNotesComponent extends StatefulWidget {
  final MatchUpNotesViewmodel viewModel;
  final bool isMobile;
  final List<MatchUp> matchUps;

  const MatchUpNotesComponent({super.key, required this.viewModel, required this.isMobile, required this.matchUps, });

  @override
  State createState() => isMobile ? _MobileMatchUpNotesState() : _DesktopMatchUpNotesState();

}

abstract class _AbstractMatchUpNotesState extends AbstractState<MatchUpNotesComponent> {

  MatchUpNotesViewmodel get viewModel => widget.viewModel;
  List<MatchUp> get matchUps => widget.matchUps;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    if (matchUps.isEmpty) {
      return Center(child: Column(children: [
        const Padding(padding: EdgeInsets.only(top: 64.0)),
        Text("In this tab, you can define match-ups and add notes on how to handle them", style: theme.textTheme.bodyLarge,),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        OutlinedButton(onPressed: () => _createMatchUp(context, localization), child: Text("create match-up"))
      ],),);
    }
    // TODO: implement doBuild
    throw UnimplementedError();
  }

  void _createMatchUp(BuildContext context, AppLocalization localization) {

  }
}

class _MobileMatchUpNotesState extends _AbstractMatchUpNotesState {

}

class _DesktopMatchUpNotesState extends _AbstractMatchUpNotesState {

}