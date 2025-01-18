
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
    // TODO add filters and display winrate
    return Column(children: [
      filtersWidget(context, localization, dimens, theme),
      Expanded(
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
      )
    ],);

  }

  Widget filtersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  Widget filterTextInput({required String labelText, TextEditingController? controller}) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
  );

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
    return ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final noteEditingContext = widget.viewModel.replayNoteEditingContextMap[replay];
          if (noteEditingContext == null) {
            if (replay.notes?.trim().isEmpty ?? true) {
              return OutlinedButton(onPressed: () => widget.viewModel.editNote(replay), child: Text(localization.addNotes));
            } else {
              return Row(children: [
                Expanded(
                    child: Text(replay.notes!, textAlign: TextAlign.center,)),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => widget.viewModel.editNote(replay),
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
                      controller: noteEditingContext.controller,
                      decoration: InputDecoration(
                        labelText: localization.notes,
                        border: OutlineInputBorder(),
                      ),
                    ),)
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => widget.viewModel.saveNotes(replay, noteEditingContext.controller.text),
                  child: Text(localization.save),
                ),
                const SizedBox(width: 16),
              ],),
            );
          }
        }
    );
  }

  Widget vsText(ThemeData theme, Replay replay) => Text("vs ${replay.opposingPlayer.name}", style: theme.textTheme.titleLarge,);

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
        Text("Elo: ${player.beforeElo} -> ${player.afterElo}"),
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
    return playerPickContainer(children);
  }
}

class _MobileGameByGameComponentState extends _AbstractGameByGameComponentState {

  @override
  Widget filtersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO: implement filtersWidget
    return Container();
  }

  @override
  Widget playWidgetContainer(List<Widget> children) =>
      Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children,);

  @override
  Widget playerPickContainer(List<Widget> children) => Column(mainAxisSize: MainAxisSize.min, children: children,);

  @override
  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Column(children: [
      Row(children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 32.0), child: vsText(theme, replay),),
        if (replay.gameOutput != GameOutput.UNKNOWN)
          winLooseWidget(theme, replay)
      ],),
      // opponent team
      Row(
        children: replay.opposingPlayer.team
            .map((pokemon) =>
        // TODO open dialog on click to show open teamsheet of particular pokemon if match was ots?
        Expanded(child: widget.viewModel.pokemonImageService.getPokemonSprite(pokemon)))
            .toList(),
      ),
      const SizedBox(height: 4,),
      viewReplayButton(localization, replay)
    ],);
  }
}

class _DesktopGameByGameComponentState extends _AbstractGameByGameComponentState with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget filtersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    // TODO: implement filtersWidget
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2.0
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: GridView(
              shrinkWrap: true,  // Shrinks to the size of its children
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,  // Number of columns in the grid
                mainAxisSpacing: 4, // Spacing between rows
                crossAxisSpacing: 20, // Spacing between columns
                childAspectRatio: 4, // Aspect ratio of each grid item
              ),
              children: [
                filterTextInput(labelText: "Opponent Min Elo"),
                filterTextInput(labelText: "Opponent Max Elo"),
              ],  // Explicitly specify a list of widgets
            ),),
          TabBar(
            controller: _tabController,
            onTap: (index) => widget.viewModel.onPokemonFilterTabSelected(index),
            tabs: Iterable.generate(6, (index) => index).map((index) => Text("Pokemon ${index + 1}", style: theme.textTheme.labelLarge,)).toList(),
          ),
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 140),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TabBarView(controller: _tabController, children: Iterable.generate(6, (index) => index).map((index) => _pokemonFilterWidget(context, localization, dimens, theme, index)).toList()),),),


          Align(alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [OutlinedButton(onPressed: () {}, child: Text("Clear")), SizedBox(width: 16.0,), OutlinedButton(onPressed: () {}, child: Text("Apply"))],
              ),),)
        ],),
      ),
    );
  }

  Widget _pokemonFilterWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, int index) {
    return GridView(
      shrinkWrap: true,  // Shrinks to the size of its children
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,  // Number of columns in the grid
        mainAxisSpacing: 4, // Spacing between rows
        crossAxisSpacing: 20, // Spacing between columns
        childAspectRatio: 6, // Aspect ratio of each grid item
      ),
      children: [
        filterTextInput(labelText: "Pokemon ${index + 1}"),
        filterTextInput(labelText: "Item"),
        filterTextInput(labelText: "Ability"),
        filterTextInput(labelText: "Tera Type"),
        filterTextInput(labelText: "Move 1"),
        filterTextInput(labelText: "Move 2"),
        filterTextInput(labelText: "Move 3"),
        filterTextInput(labelText: "Move 4")
      ],  // Explicitly specify a list of widgets
    );
  }

  @override
  Widget playWidgetContainer(List<Widget> children) => Row(children: children,);

  @override
  Widget playerPickContainer(List<Widget> children) => Row(mainAxisSize: MainAxisSize.min, children: children,);

  @override
  Widget gbgHeader(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, Replay replay) {
    return Row(children: [
      Padding(padding: EdgeInsets.only(left: 32.0), child: vsText(theme, replay),),
      SizedBox(width: 8,),
      // opponent team
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: replay.opposingPlayer.team
            .map((pokemon) =>
        // TODO open dialog on click to show open teamsheet of particular pokemon if match was ots?
        widget.viewModel.pokemonImageService.getPokemonSprite(pokemon))
            .toList(),
      ),
      SizedBox(width: 16,),
      if (replay.gameOutput != GameOutput.UNKNOWN)
        ...[
          winLooseWidget(theme, replay),
          SizedBox(width: 16,),
        ],
      viewReplayButton(localization, replay)
    ],);
  }
}
