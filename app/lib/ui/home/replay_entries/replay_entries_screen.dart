import 'package:app2/ui/core/themes/colors.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/core/widgets/grid_listview.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../data/models/replay.dart';
import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';


class ReplayEntriesComponent extends StatefulWidget {
  final ReplayEntriesViewModel viewModel;

  const ReplayEntriesComponent({super.key, required this.viewModel});


  @override
  _ReplayEntriesComponentState createState() => _ReplayEntriesComponentState();
}

class _ReplayEntriesComponentState extends AbstractState<ReplayEntriesComponent> {

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
                  Center(child: Text('', style: theme.textTheme.titleMedium,),),
                  Center(child: Text('Replay URL', style: theme.textTheme.titleMedium),),
                  Center(child: Text('Opposing Team', style: theme.textTheme.titleMedium),),
                  Center(child: Text('Notes', style: theme.textTheme.titleMedium),),
                  Center(child: Text('', style: theme.textTheme.titleMedium,),),
                ],
                rowBuilder: (context, index) {
                  final Replay replay = widget.viewModel.replays[index];
                  final replayLink = replay.uri.toString().replaceFirst('.json', '');
                  Color? color; // TODO use it
                  if (replay.gameOutput == GameOutput.WIN) {
                    color = AppColors.winBackgroundColor;
                  } else if (replay.gameOutput == GameOutput.LOSS) {
                    color = AppColors.looseBackgroundColor;
                  }
                  return GridListViewRow(decoration: BoxDecoration(color: color),
                      children: [
                        Center(child: Text((index + 1).toString()),),
                        Center(
                          child: TextButton(
                            onPressed: () => widget.viewModel.openLink(replayLink),
                            child: Text(replayLink, overflow: TextOverflow.ellipsis, style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),),
                          ),),
                        Center(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: replay.opposingPlayer.team
                              .map((pokemon) =>
                              Padding(padding: EdgeInsets.symmetric(horizontal: 4), child:
                              widget.viewModel.pokemonImageService.getPokemonSprite(pokemon),))
                              .toList(),
                        ),),
                        Center(child: Text(replay.notes ?? ''),),
                        Center(child: IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.viewModel.removeReplay(replay))),
                      ]
                  );
                },
                itemCount: widget.viewModel.replays.length
            )
        ),
        Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32, top: 16),
            child: Row(
              children: [
                Expanded(
                  // TODO there is a problem when hovering on it targetElement == domElement... should be fixed in flutter release 3.28
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
            ))
      ],
    );
  }
}