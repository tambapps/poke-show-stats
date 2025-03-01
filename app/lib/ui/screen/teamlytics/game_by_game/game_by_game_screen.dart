import '../../../../data/models/replay.dart';
import '../../../core/dialogs.dart';
import '../../../core/widgets/pokepaste_widget.dart';
import '../../../core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/utils.dart';
import '../../../core/widgets.dart';
import './game_by_game_viewmodel.dart';

class GameByGameComponent extends StatefulWidget {
  final GameByGameViewModel viewModel;
  final bool isMobile;
  final ReplayFiltersWidget filtersWidget;
  final List<Replay> filteredReplays;

  const GameByGameComponent({super.key, required this.viewModel, required this.isMobile, required this.filtersWidget, required this.filteredReplays});


  @override
  State createState() => isMobile ? _MobileGameByGameComponentState() : _DesktopGameByGameComponentState();
}

abstract class _AbstractGameByGameComponentState extends AbstractState<GameByGameComponent> {

  GameByGameViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return ListView.separated(
      padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index == 0) {
            return widget.filtersWidget;
          } else if (index == 1) {
            return headerWidget(context, localization, dimens, theme);
          }
          final replay = widget.filteredReplays[index - 2];
          return _gbgWidget(context, localization, dimens, theme, replay);
        },
        separatorBuilder: (context, index) {
          if (index <= 1) return Container();
          return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
            color: Colors.grey,
            thickness: 2,
            height: 1,
          ),);
        },
        itemCount: widget.filteredReplays.length + 2 // + 2 because filters and header component
    );
  }

  Widget headerWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final double? winRateRatio = widget.filteredReplays.isEmpty ? null
             : widget.filteredReplays.where((replay) => replay.gameOutput == GameOutput.WIN).length.toDouble() / widget.filteredReplays.length.toDouble();
    final textStyle = theme.textTheme.titleLarge;
    return Padding(
        padding: const EdgeInsets.only(left: 32.0, top: 8.0, bottom: 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (winRateRatio != null)
            Text("Win rate ${(winRateRatio * 100).toStringAsFixed(1)}%", style: textStyle),
        ],
      ),
    );
  }

  Widget playWidgetContainer(List<Widget> children);

  Widget _gbgWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Column(children: [
      gbgHeader(context, localization, dimens, theme, replay),
      const SizedBox(height: 16.0,),
      playWidgetContainer([
        Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.otherPlayer),),
        Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.opposingPlayer),),
      ]),
      const SizedBox(height: 8.0,),
      _gbgNotesWidget(context, localization, dimens, theme, replay),
      const SizedBox(height: 8.0,),
    ],);
  }

  Widget _gbgNotesWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    final noteEditingContext = viewModel.getEditingContext(replay);
    return ListenableBuilder(
      listenable: noteEditingContext,
      builder: (context, _) {
        final controller =  noteEditingContext.controller;
        if (controller == null) {
          if (replay.notes?.trim().isEmpty ?? true) {
            return OutlinedButton(onPressed: () => noteEditingContext.edit(), child: Text(localization.addNotes));
          } else {
            return Row(children: [
              Expanded(
                  child: Text(replay.notes!, textAlign: TextAlign.center,)),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => noteEditingContext.edit(initialValue: replay.notes),
                child: Text(localization.editNotes),
              ),
              const SizedBox(width: 16),
            ],);
          }
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [
              Expanded(
                  child: ConstrainedBox(constraints: BoxConstraints(
                    maxHeight: 200, // give max height to prevent from overflowing
                  ), child: TextField(
                    maxLines: null,
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: localization.notes,
                      border: OutlineInputBorder(),
                    ),
                  ),)
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => viewModel.saveNotes(replay, noteEditingContext),
                child: Text(localization.save),
              ),
              const SizedBox(width: 16),
            ],),
          );
        }
      },
    );
  }

  Widget vsText(ThemeData theme, Replay replay) => SelectableText("vs ${replay.opposingPlayer.name}", style: theme.textTheme.titleLarge,);

  Widget viewReplayButton(AppLocalization localization, Replay replay) => TextButton(
    onPressed: () => openLink(replay.uri.toString().replaceFirst('.json', '')),
    child: Text(localization.replay, overflow: TextOverflow.ellipsis, style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),),
  );

  Widget winLooseWidget(ThemeData theme, Replay replay) => Container(
    decoration: BoxDecoration(
      color: replay.gameOutput == GameOutput.WIN ? Colors.green : Colors.red,
      borderRadius: BorderRadius.circular(10), // Rounded corners
    ),
    child:  SizedBox(width: 45, height: 45,
      child: Center(child: Text(replay.gameOutput == GameOutput.WIN ? 'W' : 'L', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),),);

  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay);

  Widget _playerWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay, PlayerData player) {
    bool isOpponent = replay.opposingPlayer.name == player.name;

    return Column(children: [
      Text(isOpponent ? localization.opponent : localization.you),
      if (player.beforeElo != null && player.afterElo != null)
        Text(player.beforeElo != player.afterElo ? "Elo: ${player.beforeElo} -> ${player.afterElo}" : "Elo: ${player.beforeElo}"),
      _playerPickWidget(context, localization, dimens, theme, replay, player)
    ],);
  }

  Widget playerPickContainer(List<Widget> children);

  Widget _playerPickWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay, PlayerData player) {
    List<Widget> children = player.selection.map((pokemon) {
      final String? teraType = player.terastallization?.pokemon == pokemon ? player.terastallization?.type : null;
      return SizedBox(
        height: 128.0,
        width: 128.0,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 0.65,
              child: viewModel.pokemonResourceService.getPokemonArtwork(pokemon),
            ),
            if (teraType != null)
              Positioned(
                top: dimens.pokepastePokemonIconsOffset,
                right: 0,
                child: viewModel.pokemonResourceService.getTeraTypeSprite(teraType, width: 50, height: 50),
              ),
          ],
        ),
      );
    }).toList();
    return playerPickContainer(children);
  }
}

class _MobileGameByGameComponentState extends _AbstractGameByGameComponentState {

  @override
  Widget playWidgetContainer(List<Widget> children) =>
      Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children,);

  @override
  Widget playerPickContainer(List<Widget> children) => Column(mainAxisSize: MainAxisSize.min, children: children,);

  @override
  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Column(children: [
      Row(children: [
        const SizedBox(width: 32.0,),
        if (replay.gameOutput != GameOutput.UNKNOWN)
          ...[winLooseWidget(theme, replay), const SizedBox(width: 32.0,)],
        vsText(theme, replay),
      ],),
      // opponent team
      Row(
        children: replay.opposingPlayer.team
            .map((pokemon) =>
        Expanded(child: viewModel.pokemonResourceService.getPokemonSprite(pokemon)))
            .toList(),
      ),
      const SizedBox(height: 4,),
      if (replay.data.isOts)
        ...[OutlinedButton(onPressed: () => showTeamSheetDialog(
            context: context,
            title: "${replay.opposingPlayer.name}'s team",
            pokepaste: replay.opposingPlayer.pokepaste!,
            pokemonResourceService: viewModel.pokemonResourceService), child: Text("OTS")), const SizedBox(height: 4.0,)],
      viewReplayButton(localization, replay)
    ],);
  }
}

class _DesktopGameByGameComponentState extends _AbstractGameByGameComponentState with TickerProviderStateMixin {

  @override
  Widget playWidgetContainer(List<Widget> children) => Row(children: children,);

  @override
  Widget playerPickContainer(List<Widget> children) => Row(mainAxisSize: MainAxisSize.min, children: children,);

  @override
  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Row(children: [
      SizedBox(width: 32.0,),
      if (replay.gameOutput != GameOutput.UNKNOWN)
        ...[
          winLooseWidget(theme, replay),
          const SizedBox(width: 16.0,),
        ],
      vsText(theme, replay),
      SizedBox(width: 8,),
      // opponent team
    ...replay.opposingPlayer.team
        .map((pokemon) =>
        viewModel.pokemonResourceService.getPokemonSprite(pokemon)),
      const SizedBox(width: 16.0,),
      if (replay.data.isOts)
      ...[OutlinedButton(onPressed: () => showTeamSheetDialog(
          context: context,
          title: "${replay.opposingPlayer.name}'s team",
          pokepaste: replay.opposingPlayer.pokepaste!,
          pokemonResourceService: viewModel.pokemonResourceService), child: Text("OTS")), const SizedBox(width: 16.0,)],
      viewReplayButton(localization, replay)
    ],);
  }
}
