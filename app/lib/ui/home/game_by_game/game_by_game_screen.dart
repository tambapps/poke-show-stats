
import 'dart:math';

import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

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
    // TODO add filters
    return Expanded(
        child: ListView.separated(
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
        )
    );
  }

  Widget _gbgWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Column(children: [
      _gbgHeader(context, localization, dimens, theme, replay),
      _playerWidget(context, localization, dimens, theme, replay, replay.otherPlayer),
      SizedBox(width: 8,),
      _playerWidget(context, localization, dimens, theme, replay, replay.opposingPlayer),
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
        Container(
          decoration: BoxDecoration(
            color: replay.gameOutput == GameOutput.WIN ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child:  SizedBox(width: 45, height: 45,
            child: Center(child: Text(replay.gameOutput == GameOutput.WIN ? 'W' : 'L', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),),)
    ],);
  }

  Widget _playerWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay, PlayerData player) {
    return Row(children: [
      _playerPickWidget(context, localization, dimens, theme, replay, player)
    ],);
  }

  // TODO displayed who terad by display the tera icon on the specific pokemon
  Widget _playerPickWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay, PlayerData player) {
    List<List<Widget>> childrenPairs = [];
    for (int pair = 0; pair < 2; pair++) {
      List<String> pokemons = player.selection.sublist(pair * 2, min(player.selection.length, pair * 2 + 2));
      childrenPairs.add(pokemons.map((pokemon) => widget.viewModel.pokemonImageService.getPokemonSprite(pokemon)).toList());
    }
    bool isOpponent = replay.opposingPlayer.name == player.name;
    return Column(children: [
      Text(isOpponent ? localization.theirPick : localization.yourPick),
      ...childrenPairs.map((pair)=> Row(children: pair,))
    ],);
  }
}