import 'package:pokemon_core/pokemon_core.dart';

import '../../../../data/models/replay.dart';
import '../../../core/dialogs.dart';
import '../../../core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
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
    return ValueListenableBuilder(valueListenable: viewModel.matchMode, builder: (context, matchMode, _) {
      if (matchMode) {
        return byMatch(context, localization, dimens, theme);
      }
      return byGame(context, localization, dimens, theme);
    });
  }

  double _countWins(List<List<Replay>> matches) {
    return matches.where((replays) {
      final wins = replays.where((replay) => replay.gameOutput == GameOutput.WIN).length;
      return wins > replays.length / 2;
    }).length.toDouble();
  }

  Widget byMatch(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final matches = viewModel.filteredMatches;
    return ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index == 0) {
            return widget.filtersWidget;
          } else if (index == 1) {
            final double? winRateRatio = matches.isNotEmpty ? _countWins(matches) / matches.length.toDouble() : null;
            String? warning;
            if (widget.filtersWidget.viewModel.hasSelectionFilters) {
              warning = "⚠️ As you specified selection filters, some matches might miss game(s) ⚠️";
            }
            return headerWidget(context, localization, dimens, theme, winRateRatio, warning: warning);
          }
          final match = matches[index - 2];
          if (match.length == 1) {
            return _gbgWidget(context, localization, dimens, theme, match.first);
          }
          return _mbmWidget(context, localization, dimens, theme, match);
        },
        separatorBuilder: (context, index) {
          if (index <= 1) return Container();
          return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
            color: Colors.grey,
            thickness: 2.0,
            height: 1,
          ),);
        },
        itemCount: matches.length + 2 // + 2 because filters and header component
    );
  }

  Widget byGame(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final filteredReplays = widget.filteredReplays;
    return ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index == 0) {
            return widget.filtersWidget;
          } else if (index == 1) {
            final double? winRateRatio = widget.filteredReplays.isEmpty ? null
                : widget.filteredReplays.where((replay) => replay.gameOutput == GameOutput.WIN).length.toDouble() / widget.filteredReplays.length.toDouble();
            return headerWidget(context, localization, dimens, theme, winRateRatio);
          }
          final replay = filteredReplays[index - 2];
          return _gbgWidget(context, localization, dimens, theme, replay);
        },
        separatorBuilder: (context, index) {
          if (index <= 1 || index >= filteredReplays.length + 2) return Container();
          final previous = filteredReplays[index - 2];
          final next = filteredReplays[index - 1];
          // using a bigger separator when we change match (BO)
          final thickness = next.isNextBattleOf(previous) ? 2.0 : 7.0;
          return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
            color: Colors.grey,
            thickness: thickness,
            height: 1,
          ),);
        },
        itemCount: filteredReplays.length + 2 // + 2 because filters and header component
    );
  }

  Widget warningText(String text) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget headerWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, double? winRateRatio, {String? warning}) {
    final textStyle = theme.textTheme.titleLarge;

    final gameModeSwitch = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
      Text("By game"),
      Switch(
        value: viewModel.matchMode.value,
        onChanged: (bool value) => (viewModel.matchMode.value = value),
      ),
      Text("By match"),
    ]);
    return Padding(
        padding: const EdgeInsets.only(right: 32.0, left: 32.0, top: 8.0, bottom: 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (warning != null)
            warningText(warning),
          Row(
            children: [
              if (winRateRatio != null)
                Text("Win rate ${(winRateRatio * 100).toStringAsFixed(1)}%", style: textStyle),
              Spacer(flex: 1,),
              if (!Dimens.of(context).isMobile)
                gameModeSwitch
            ],
          ),
          if (Dimens.of(context).isMobile)
            Padding(padding: EdgeInsets.only(top: 16.0), child: gameModeSwitch,)
        ],
      ),
    );
  }

  Widget playWidgetContainer(List<Widget> children);

  Widget _mbmWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<Replay> match) {
    final indexListener = ValueNotifier(0);
    return Column(
      children: [
        mbmHeader(context, localization, dimens, theme, match, indexListener),
        const SizedBox(height: 16.0,),
        ValueListenableBuilder(valueListenable: indexListener, builder: (_, currentIndex, __) {
          return Column(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: IndexedStack(
                key: ValueKey<int>(currentIndex), // important for animation to trigger
                index: currentIndex,
                children: match.map((replay) => Column(children: [
                  playWidgetContainer([
                    Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.otherPlayer),),
                    Expanded(child: _playerWidget(context, localization, dimens, theme, replay, replay.opposingPlayer),),
                  ]),
                  const SizedBox(height: 8.0,),
                  _gbgNotesWidget(context, localization, dimens, theme, replay),
                ],)).toList(),
              ),
            ),
            const SizedBox(height: 8.0,),
          ],);
        })
      ],
    );
  }

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

  Widget viewReplayButton(AppLocalization localization, Replay replay, {int? gameIndex}) => TextButton(
    onPressed: () => openLink(replay.uri.toString().replaceFirst('.json', '')),
    child: Text(gameIndex != null ? "G${gameIndex + 1} ${localization.replay}" : localization.replay, overflow: TextOverflow.ellipsis, style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),),
  );

  Widget winLooseWidget(ThemeData theme, Replay replay, {bool selected = false}) {
    Color color;
    String text;
    switch (replay.gameOutput) {
      case GameOutput.WIN:
        text = 'W';
        color = Colors.green;
        break;
      case GameOutput.LOSS:
        text = 'L';
        color = Colors.red;
        break;
      case GameOutput.UNKNOWN:
        text = 'U';
        color = Colors.black12;
        break;
    }
    final component = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child:  SizedBox(width: 45, height: 45,
        child: Center(child: Text(text, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),),);
    if (!selected) {
      return component;
    }
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: component);
  }

  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay);
  Widget mbmHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<Replay> replays, ValueNotifier indexNotifier);

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
      final String? teraType = player.terastallization?.pokemon == Pokemon.normalizeToBase(pokemon) ? player.terastallization?.type : null;
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
  Widget mbmHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<Replay> replays, ValueNotifier indexNotifier) {
    return ValueListenableBuilder(valueListenable: indexNotifier, builder: (context, currentIndex, _) {
      final replay = replays[currentIndex];
      return Column(children: [
        vsText(theme, replay),
        const SizedBox(height: 8,),
        Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ...replays.indexed.map((tuple) => Padding(padding: EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              child: Tooltip(message: "Click to show game", child: winLooseWidget(theme, tuple.$2, selected: tuple.$1 == currentIndex),),
              onTap: () => (indexNotifier.value = tuple.$1),
            ),))
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
        viewReplayButton(localization, replay, gameIndex: currentIndex)
      ],);
    });
  }

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
  Widget mbmHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, List<Replay> replays, ValueNotifier indexNotifier) {
    return ValueListenableBuilder(valueListenable: indexNotifier, builder: (context, currentIndex, _) {
      final replay = replays[currentIndex];
      return Row(children: [
        SizedBox(width: 32.0,),
        ...replays.indexed.map((tuple) => Padding(padding: EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            child: Tooltip(message: "Click to show game", child: winLooseWidget(theme, tuple.$2, selected: tuple.$1 == currentIndex),),
            onTap: () => (indexNotifier.value = tuple.$1),
          ),)),
        const SizedBox(width: 8,),
        vsText(theme, replay),
        const SizedBox(width: 8,),
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
        viewReplayButton(localization, replay, gameIndex: currentIndex)
      ],);
    });
  }
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
