import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:app2/ui/home/replay_entries/replay_entries_viewmodel.dart';
import 'package:flutter/material.dart';

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

  // TODO display win rate
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
        SingleChildScrollView(
          child: Column(children: [
            if (widget.viewModel.replays.isNotEmpty)
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FractionColumnWidth(0.1),
                  1: FractionColumnWidth(0.3),
                  2: FractionColumnWidth(0.3),
                  3: FractionColumnWidth(0.2),
                  4: FractionColumnWidth(0.1),
                },
                children: [
                  TableRow(children: [
                    Center(child: Text('', style: theme.textTheme.titleMedium,),),
                    Center(child: Text('Replay URL', style: theme.textTheme.titleMedium),),
                    Center(child: Text('Opposing Team', style: theme.textTheme.titleMedium),),
                    Center(child: Text('Notes', style: theme.textTheme.titleMedium),),
                    Center(child: Text('', style: theme.textTheme.titleMedium,),),
                  ]),
                  ...widget.viewModel.replays.asMap().entries.map((entry) {
                    final number = entry.key + 1;
                    final Replay replay = entry.value;
                    final replayLink = replay.uri.toString().replaceFirst('.json', '');
                    final winStatus = widget.viewModel.getWinStatus(replay);
                    Color? color;
                    if (winStatus == 1) {
                      color = Colors.greenAccent.withAlpha(50);
                    } else if (winStatus == -1) {
                      color = Colors.redAccent.withAlpha(50);
                    }
                    return TableRow(
                        decoration: BoxDecoration(color: color),
                      children: [
                        Center(child: Text(number.toString()),),
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
                          children: replay.data.player1.team
                              .map((pokemon) =>
                              Padding(padding: EdgeInsets.symmetric(horizontal: 4), child:
                              widget.viewModel.pokemonImageService.getPokemonSprite(pokemon),))
                              .toList(),
                        ),),
                        Center(child: Text(replay.notes ?? ''),),
                        Center(child: IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.viewModel.removeReplay(replay))),
                      ],
                    );
                  })
                ],
              ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                child: Row(
                  children: [
                    Expanded(
                      // TODO there is a problem when hovering on it targetElement == domElement... should be fixed in flutter release 3.28
                      child: TextField(
                        controller: widget.viewModel.addReplayURIController,
                        decoration: const InputDecoration(
                          labelText: 'Replay URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.loadReplay(),
                      child: const Text('Add'),
                    ),
                  ],
                ))
          ],),
        ),
      ],
    );
  }
}