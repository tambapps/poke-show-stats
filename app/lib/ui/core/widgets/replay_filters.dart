import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/replay.dart';

typedef ReplayPredicate = bool Function(Replay);

// TODO handle mobile
class ReplayFiltersWidget extends StatefulWidget {
  final ReplayFiltersViewModel viewModel;
  final void Function(ReplayPredicate?) applyFilters;

  const ReplayFiltersWidget({super.key, required this.viewModel, required this.applyFilters});

  @override
  State createState() => ReplayFiltersWidgetState();
}

class ReplayFiltersWidgetState extends AbstractState<ReplayFiltersWidget> with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  ReplayFiltersViewModel get viewModel => widget.viewModel;
  void Function(ReplayPredicate?) get applyFilters => widget.applyFilters;

  @override
  void initState() {
    super.initState();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), child: Text("Filters", style: theme.textTheme.titleMedium,),),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView(
              shrinkWrap: true,  // Shrinks to the size of its children
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,  // Number of columns in the grid
                mainAxisSpacing: 4, // Spacing between rows
                crossAxisSpacing: 20, // Spacing between columns
                childAspectRatio: 4, // Aspect ratio of each grid item
              ),
              children: [
                textInput(labelText: "Opponent Min Elo", controller: viewModel.minEloController, numberInput: true),
                textInput(labelText: "Opponent Max Elo", controller: viewModel.maxEloController, numberInput: true),
              ],  // Explicitly specify a list of widgets
            ),),
          TabBar(
            controller: _tabController,
            onTap: (index) => viewModel.onPokemonFilterTabSelected(index),
            tabs: Iterable.generate(6, (index) => index).map((index) => Text("Pokemon ${index + 1}", style: theme.textTheme.labelLarge,)).toList(),
          ),
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 140),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TabBarView(controller: _tabController, children: Iterable.generate(6, (index) => index).map((index) => _pokemonFilterWidget(context, localization, dimens, theme, index)).toList()),),),


          Align(alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(onPressed: () => viewModel.clearFilters(), child: Text("Clear")), const SizedBox(width: 16.0,),
                  OutlinedButton(onPressed: () => applyFilters(viewModel.getFiltersPredicate()), child: Text("Apply"))],
              ),),),
          const SizedBox(height: 8.0,),
        ],),
      ),
    );
  }

  Widget _pokemonFilterWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, int index) {
    final pokemonFilters = viewModel.getPokemonFilters(index);

    return GridView(
      shrinkWrap: true,  // Shrinks to the size of its children
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,  // Number of columns in the grid
        mainAxisSpacing: 8, // Spacing between rows
        crossAxisSpacing: 20, // Spacing between columns
        childAspectRatio: 6, // Aspect ratio of each grid item
      ),
      children: [
        textInput(labelText: "Pokemon ${index + 1}", controller: pokemonFilters.pokemonNameController),
        textInput(labelText: "Item", controller:  pokemonFilters.itemController),
        textInput(labelText: "Ability", controller:  pokemonFilters.abilityController),
        textInput(labelText: "Tera Type", controller:  pokemonFilters.teraTypeController),
        ...List.generate(4, (index) => textInput(labelText: "Move ${index + 1}", controller: pokemonFilters.moveControllers[index]))
      ],  // Explicitly specify a list of widgets
    );
  }

  Widget textInput({required String labelText, TextEditingController? controller, bool numberInput = false}) => Padding(
    padding: EdgeInsets.only(top: 8.0),
    child: TextField(
      controller: controller,
      keyboardType: numberInput ? TextInputType.number : null,
      inputFormatters: numberInput ? [
        FilteringTextInputFormatter.digitsOnly, // Allows only digits
      ] : null,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    ),
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class ReplayFiltersViewModel extends ChangeNotifier {

  final _Filters _filters = _Filters();


  TextEditingController get minEloController => _filters.minEloController;
  TextEditingController get maxEloController => _filters.maxEloController;

  int _pokemonFilterTabIndex = 0;
  int get pokemonFilterTabIndex => _pokemonFilterTabIndex;
  void onPokemonFilterTabSelected(int index) => _pokemonFilterTabIndex = index;

  ReplayPredicate? getFiltersPredicate() => _filters.getPredicate();

  void clearFilters() => _filters.clear();

  PokemonFilters getPokemonFilters(int index) => _filters.pokemons[index];

  @override
  void dispose() {
    super.dispose();
  }
}

class _Filters {

  final minEloController = TextEditingController();
  final maxEloController = TextEditingController();
  final List<PokemonFilters> pokemons = List.generate(6, (_) => PokemonFilters());

  ReplayPredicate? getPredicate() {
    List<ReplayPredicate> predicates = [];

    if (minEloController.text.trim().isNotEmpty) {
      final minElo = int.tryParse(minEloController.text.trim()) ?? 0;
      // TODO don't take into account first games of BO3
      predicates.add((replay) => replay.opposingPlayer.beforeElo != null && replay.opposingPlayer.beforeElo! >= minElo);
    }
    if (maxEloController.text.trim().isNotEmpty) {
      final minElo = int.tryParse(maxEloController.text.trim()) ?? 0;
      // TODO don't take into account first games of BO3
      predicates.add((replay) => replay.opposingPlayer.beforeElo != null && replay.opposingPlayer.beforeElo! <= minElo);
    }
    for (PokemonFilters pokemonFilters in pokemons) {
      ReplayPredicate? pokemonPredicate = pokemonFilters.getPredicate();
      if (pokemonPredicate != null) {
        predicates.add(pokemonPredicate);
      }
    }
    return predicates.isNotEmpty ? (replay) => predicates.every((predicate) => predicate(replay))
        : null;
  }

  void clear() {
    minEloController.clear();
    maxEloController.clear();
    for (PokemonFilters pokemonFilters in pokemons) {
      pokemonFilters.clear();
    }
  }

  void dispose() {
    minEloController.dispose();
    maxEloController.dispose();
    for (PokemonFilters pokemonFilters in pokemons) {
      pokemonFilters.dispose();
    }
  }
}

class PokemonFilters {
  final pokemonNameController = TextEditingController();
  final itemController = TextEditingController();
  final abilityController = TextEditingController();
  final teraTypeController = TextEditingController();
  final moveControllers = List.generate(4, (_) => TextEditingController());

  ReplayPredicate? getPredicate() {
    List<ReplayPredicate> predicates = [];
    if (pokemonNameController.text.trim().isNotEmpty) {
      final pokemon = pokemonNameController.text.trim().replaceAll(' ', '-');
      // TODO enhance pokemon names matches (e.g. with accents, form names...)
      predicates.add((replay) => replay.opposingPlayer.team.any((pokemonName) => pokemon.toLowerCase() == pokemonName.toLowerCase()));
    }
    // TODO cannot do other filters yet as I don't store team sheet from replay
    return predicates.isNotEmpty ? (replay) => predicates.every((predicate) => predicate(replay)) : null;
  }

  void clear() {
    pokemonNameController.clear();
    itemController.clear();
    abilityController.clear();
    teraTypeController.clear();
    for (TextEditingController moveController in moveControllers) {
      moveController.clear();
    }
  }

  void dispose() {
    pokemonNameController.dispose();
    itemController.dispose();
    abilityController.dispose();
    teraTypeController.dispose();
    for (TextEditingController moveController in moveControllers) {
      moveController.dispose();
    }
  }
}