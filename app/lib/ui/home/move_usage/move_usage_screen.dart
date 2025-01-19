

import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../core/widgets.dart';
import '../../core/widgets/replay_filters.dart';
import 'move_usage_viewmodel.dart';

class MoveUsageComponent extends StatefulWidget {
  final MoveUsageViewModel viewModel;
  final bool isMobile;

  const MoveUsageComponent({super.key, required this.viewModel, required this.isMobile});

  @override
  _MoveUsageComponentState createState() => isMobile ? _MobileMoveUsageComponentState() : _DesktopMoveUsageComponentState();
}


abstract class _MoveUsageComponentState extends AbstractState<MoveUsageComponent> {
  @override
  MoveUsageViewModel get viewModel => widget.viewModel;


  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final pokepaste = viewModel.pokepaste;
    if (pokepaste == null) {
      return _cantDisplay("Please enter a pokepaste in the Home tab to consult move usages");
    }
    final replays = viewModel.filteredReplays;
    if (replays.isEmpty) {
      return _cantDisplay("Please enter a replays in the Replay Entries tab to consult move usages");
    }
    final filtersViewModel = ReplayFiltersViewModel();
    return Column(children: [
      ReplayFiltersWidget(viewModel: filtersViewModel, applyFilters: (replayPredicate) => viewModel.applyFilters(replayPredicate)),
      moveUsagesWidget(pokepaste, replays)
    ],);

  }

  Widget moveUsagesWidget(Pokepaste pokepaste, List<Replay> replays);

  Widget _cantDisplay(String text) => Center(
    child: Text(text),
  );
  Widget pokemonMoveUsagesWidget(List<Replay> replays, Pokemon pokemon) => Text(pokemon.name);
}

class _MobileMoveUsageComponentState extends _MoveUsageComponentState {

  @override
  Widget moveUsagesWidget(Pokepaste pokepaste, List<Replay> replays) {
    // TODO: implement moveUsagesWidget
    throw UnimplementedError();
  }
  
}

class _DesktopMoveUsageComponentState extends _MoveUsageComponentState {

  @override
  Widget moveUsagesWidget(Pokepaste pokepaste, List<Replay> replays) {
    final pokemons = pokepaste.pokemons;
    List<Row> pokemonRows = [];
    int nbRows = (pokemons.length % 3 == 0 ? pokemons.length / 2 : pokemons.length / 2 + 1).toInt();
    for (int row = 0; row < nbRows; row++) {
      List<Widget> rowChildren = [];
      for (int i = row * 3; i < row * 3 + 3 && i < pokemons.length; i++) {
        final pokemon = pokemons[i];
        rowChildren.add(Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: pokemonMoveUsagesWidget(replays, pokemon),),));
      }
      pokemonRows.add(Row(children: rowChildren,));
    }
    return Column(children: pokemonRows,);
  }

}

