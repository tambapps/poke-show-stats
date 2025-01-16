
import 'package:app2/data/models/replay.dart';
import 'package:flutter/material.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import 'game_by_game_viewmodel.dart';

class GameByGameComponent extends StatefulWidget {
  final GameByGameViewModel viewModel;
  final bool isMobile;

  const GameByGameComponent({super.key, required this.viewModel, required this.isMobile});


  @override
  State createState() => isMobile ? _MobileGameByGameComponentState() : _DesktopGameByGameComponentState();
}

abstract class _AbstractGameByGameComponentState extends AbstractState<GameByGameComponent> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO add filters
    return ListView.separated(
        itemBuilder: (context, index) {
          final replay = widget.viewModel.replays[index];
          return _gbgWidget(context, localization, dimens, theme, replay);
        },
        separatorBuilder: (context, index) {
          return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
            color: Colors.grey,
            thickness: 2,
            height: 1,
          ),);
        },
        itemCount: widget.viewModel.replays.length
    );

  }

  Widget playWidgetContainer(List<Widget> children);

  Widget _gbgWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Column(children: [
      _gbgHeader(context, localization, dimens, theme, replay),
      SizedBox(height: 16.0,),
      playWidgetContainer([
        Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.otherPlayer),),
        Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.opposingPlayer),),
      ]),
    ],);
  }

  Widget _gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Row(children: [
      Text("vs ${replay.opposingPlayer.name}", style: theme.textTheme.titleLarge,),
      SizedBox(width: 8,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: replay.opposingPlayer.team
            .map((pokemon) =>
        // TODO open dialog on click to show open teamsheet of particular pokemon if match was ots?
        Padding(padding: EdgeInsets.symmetric(horizontal: 4), child:
        widget.viewModel.pokemonImageService.getPokemonSprite(pokemon),))
            .toList(),
      ),
      SizedBox(width: 16,),
      if (replay.gameOutput != GameOutput.UNKNOWN)
        ...[
          Container(
            decoration: BoxDecoration(
              color: replay.gameOutput == GameOutput.WIN ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child:  SizedBox(width: 45, height: 45,
              child: Center(child: Text(replay.gameOutput == GameOutput.WIN ? 'W' : 'L', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),),),
          SizedBox(width: 16,),
        ],
      TextButton(
        onPressed: () => openLink(replay.uri.toString().replaceFirst('.json', '')),
        child: Text('Replay', overflow: TextOverflow.ellipsis, style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),),
      )
    ],);
  }

  Widget _playerWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay, PlayerData player) {
    bool isOpponent = replay.opposingPlayer.name == player.name;

    return Column(children: [
      Text(isOpponent ? localization.opponent : localization.you),
      if (player.beforeElo != null && player.afterElo != null)
        Text("Elo: ${player.beforeElo} -> ${player.afterElo}"),
      _playerPickWidget(context, localization, dimens, theme, replay, player)
    ],);
  }

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
              child: widget.viewModel.pokemonImageService.getPokemonArtwork(pokemon),
            ),
            if (teraType != null)
              Positioned(
                top: dimens.pokepastePokemonIconsOffset,
                right: 0,
                child: widget.viewModel.pokemonImageService.getTeraTypeSprite(teraType, width: 50, height: 50),
              ),
          ],
        ),
      );
    }).toList();
    return Row(mainAxisSize: MainAxisSize.min, children: children,);
  }
}

class _MobileGameByGameComponentState extends _AbstractGameByGameComponentState {

  @override
  Widget playWidgetContainer(List<Widget> children) => Column(children: children,);

}

class _DesktopGameByGameComponentState extends _AbstractGameByGameComponentState {

  @override
  Widget playWidgetContainer(List<Widget> children) => Row(children: children,);
}
