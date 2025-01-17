import 'package:app2/ui/core/themes/colors.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/core/widgets/grid_listview.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_viewmodel.dart';
import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/utils.dart';


class ReplayEntriesComponent extends StatefulWidget {
  final ReplayEntriesViewModel viewModel;
  final bool isMobile;

  const ReplayEntriesComponent({super.key, required this.viewModel, required this.isMobile});

  @override
  State createState() => isMobile ? _MobileReplayEntriesComponentState() : _DesktopReplayEntriesComponentState();
}

abstract class _AbstractReplayEntriesComponentState extends AbstractState<ReplayEntriesComponent> {

  Widget addReplayRow() => Row(
    children: [
      Expanded(
        child: TextField(
          maxLines: null,
          controller: widget.viewModel.addReplayURIController,
          decoration: const InputDecoration(
            labelText: 'Replay URL(s)',
            border: OutlineInputBorder(),
          ),
        )
        ,
      ),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: () => widget.viewModel.loadReplays(),
        child: const Text('Add'),
      ),
    ],
  );

  Widget cancelButton(Replay replay) => IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.viewModel.removeReplay(replay));

  Widget opponentTeamWidget(Replay replay) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: replay.opposingPlayer.team
        .map((pokemon) =>
    Expanded(child: widget.viewModel.pokemonImageService.getPokemonSprite(pokemon)))
        .toList(),
  );

  Widget replayLinkWidget(String replayLink) => TextButton(
    onPressed: () => openLink(replayLink.replaceFirst('.json', '')),
    child: Text(replayLink, overflow: TextOverflow.ellipsis, style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),),
  );

  Color? getGameOutputColor(Replay replay) {
    if (replay.gameOutput == GameOutput.WIN) {
      return AppColors.winBackgroundColor;
    } else if (replay.gameOutput == GameOutput.LOSS) {
      return AppColors.looseBackgroundColor;
    }
    return null;
  }
}

class _MobileReplayEntriesComponentState extends _AbstractReplayEntriesComponentState {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Flexible(flex: 9,
          fit: FlexFit.loose, // this is because we want this component to shrink when we open the keyboard
          child: ListView.separated(itemBuilder: (context, index) {
            final Replay replay = widget.viewModel.replays[index];
            final replayLink = replay.uri.toString().replaceFirst('.json', '');
            Color? color = getGameOutputColor(replay);
            return Container(
              decoration: BoxDecoration(color: color),
              child: Column(
                children: [
                  Text((index + 1).toString()),
                  replayLinkWidget(replayLink),
                  opponentTeamWidget(replay),
                  if (replay.notes != null && replay.notes!.isNotEmpty) Text(replay.notes ?? ''),
                  cancelButton(replay)
                ],),
            );
          }, separatorBuilder: (context, index) {
            return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
              color: Colors.grey,
              thickness: 2,
              height: 1,
            ),);
          }, itemCount: widget.viewModel.replays.length)
      ),
      Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
          child: ConstrainedBox(constraints: BoxConstraints(
            maxHeight: 200, // give max height to prevent from overflowing
          ), child: addReplayRow(),))
    ],);
  }
}

class _DesktopReplayEntriesComponentState extends _AbstractReplayEntriesComponentState {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)),
        ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) => widget.viewModel.loading ? child! : Padding(padding: EdgeInsets.zero),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[300], // Background color
            valueColor: AlwaysStoppedAnimation(Colors.blue), // Progress color
            minHeight: 2.0, // Height of the progress bar
          ),),

        Expanded(
            child: GridListView(
                columnWeights: {
                  0: 1,
                  1: 3,
                  2: 3,
                  3: 2,
                  4: 1,
                },
                headRow: [
                  Center(child: Text('', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),),
                  Center(child: Text('Replay URL', style: theme.textTheme.titleMedium, textAlign: TextAlign.center,),),
                  Center(child: Text('Opposing Team', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),),
                  Center(child: Text('Notes', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),),
                  Center(child: Text('', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),),
                ],
                rowBuilder: (context, index) {
                  final Replay replay = widget.viewModel.replays[index];
                  final replayLink = replay.uri.toString().replaceFirst('.json', '');
                  Color? color = getGameOutputColor(replay);
                  return GridListViewRow(decoration: BoxDecoration(color: color),
                      children: [
                        Center(child: Text((index + 1).toString()),),
                        Center(
                          child: replayLinkWidget(replayLink),),
                        Center(child: opponentTeamWidget(replay),),
                        Center(child: Text(replay.notes ?? ''),),
                        Center(child: cancelButton(replay)),
                      ]
                  );
                },
                itemCount: widget.viewModel.replays.length
            )
        ),
        Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32, top: 16),
            child: addReplayRow())
      ],
    );
  }

}