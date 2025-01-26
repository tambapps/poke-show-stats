import 'package:app2/data/services/pokemon_resource_service.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/core/widgets/auto_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/replay.dart';
import 'controlled_autocomplete.dart';

typedef ReplayPredicate = bool Function(Replay);

class ReplayFiltersWidget extends StatefulWidget {
  final ReplayFiltersViewModel viewModel;
  final void Function(ReplayPredicate?) applyFilters;
  final bool isMobile;

  const ReplayFiltersWidget({super.key, required this.viewModel, required this.applyFilters, required this.isMobile});

  @override
  State createState() => isMobile ? _MobileReplayFiltersWidgetState() : _DesktopReplayFiltersWidgetState();
}

// doesn't extend AbstractViewModelState because the parent component should be responsible of disposing this component's viewModel
abstract class _AbstractReplayFiltersWidgetState extends AbstractState<ReplayFiltersWidget> with TickerProviderStateMixin {

  late TabController _tabController;
  ReplayFiltersViewModel get _viewModel => widget.viewModel;
  void Function(ReplayPredicate?) get applyFilters => widget.applyFilters;
  late _Filters _filters;

  @override
  void initState() {
    super.initState();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
    _filters = _Filters();
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text("Filters", style: theme.textTheme.titleMedium,),),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: eloFiltersWidget(context, localization, dimens, theme),),
          SizedBox(height: 16.0,),
          TabBar(
            controller: _tabController,
            isScrollable: widget.isMobile,
            onTap: (index) => _viewModel.onPokemonFilterTabSelected(index),
            tabs: Iterable.generate(6, (index) => index).map((index) => Text("Pokemon ${index + 1}", style: theme.textTheme.titleMedium,)).toList(),
          ),
          ConstrainedBox(constraints: BoxConstraints(maxHeight: dimens.pokemonFiltersTabViewHeight),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TabBarView(controller: _tabController, children: List.generate(6, (index) => _pokemonFilterWidget(context, localization, dimens, theme, index))),),),


          Align(alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(onPressed: () => _filters.clear(), child: Text("Clear")), const SizedBox(width: 16.0,),
                  OutlinedButton(onPressed: () => applyFilters(_filters.getPredicate()), child: Text("Apply"))],
              ),),),
          const SizedBox(height: 8.0,),
        ],),
      ),
    );
  }

  Widget eloFiltersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
  Widget _pokemonFilterWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, int index) {
    final pokemonFilters = _filters.pokemons[index];;

    return AutoGridView(
      columnsCount: dimens.pokemonFiltersColumnsCount,
      verticalCellSpacing: 8.0,
      horizontalCellSpacing: dimens.pokemonFiltersHorizontalSpacing,
      children: [
        autoCompleteTextInput(labelText: "Pokemon", suggestions: _viewModel.pokemonResourceService.pokemonNames, controller: pokemonFilters.pokemonNameController),
        autoCompleteTextInput(labelText: "Item", suggestions: _viewModel.pokemonResourceService.itemNames, controller: pokemonFilters.itemController),
        // TODO autocomplete ability
        autoCompleteTextInput(labelText: "Ability", suggestions: [], controller:  pokemonFilters.abilityController),
        autoCompleteTextInput(labelText: "Tera Type", suggestions: _viewModel.pokemonResourceService.teraTypes, controller:  pokemonFilters.teraTypeController),
        // TODO autocomplete moves
        ...List.generate(4, (index) => autoCompleteTextInput(labelText: "Move ${index + 1}", suggestions: [], controller: pokemonFilters.moveControllers[index]))
      ],  // Explicitly specify a list of widgets
    );
  }

  Widget autoCompleteTextInput({required String labelText, required List<String> suggestions, required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: ControlledAutoComplete<String>(
        controller: controller,
        suggestions: suggestions,
        displayStringForOption: (s) => _displayedName(s.replaceAll('-', ' ')),
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (value) => onFieldSubmitted(),
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(),
            ),
          );
        },
      ),
    );
  }

  String _displayedName(String input) {
    StringBuffer buffer = StringBuffer(input[0].toUpperCase());
    for (int i = 1; i < input.length; i++) {
      String last = input[i - 1];
      buffer.write(last == ' ' ? input[i].toUpperCase() : input[i]);
    }
    return buffer.toString();
  }

  Widget textInput({required String labelText, required TextEditingController controller, bool numberInput = false}) => Padding(
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
    _filters.dispose();
    super.dispose();
  }
}

class ReplayFiltersViewModel extends ChangeNotifier {

  ReplayFiltersViewModel({required this.pokemonResourceService});

  final PokemonResourceService pokemonResourceService;

  int _pokemonFilterTabIndex = 0;

  int get pokemonFilterTabIndex => _pokemonFilterTabIndex;
  void onPokemonFilterTabSelected(int index) => _pokemonFilterTabIndex = index;
}

class _DesktopReplayFiltersWidgetState extends _AbstractReplayFiltersWidgetState {
  @override
  Widget eloFiltersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 200.0, child: textInput(labelText: "Opponent Min Elo", controller: _filters.minEloController, numberInput: true),),
        SizedBox(width: 32.0,),
        SizedBox(width: 200.0, child: textInput(labelText: "Opponent Max Elo", controller: _filters.maxEloController, numberInput: true),),
      ],  // Explicitly specify a list of widgets
    );
  }


}
class _MobileReplayFiltersWidgetState extends _AbstractReplayFiltersWidgetState {

  @override
  Widget eloFiltersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Row(
        children: [
          Expanded(child: textInput(labelText: "Min Elo", controller: _filters.minEloController, numberInput: true)),
          SizedBox(width: 8.0,),
          Expanded(child: textInput(labelText: "Max Elo", controller: _filters.maxEloController, numberInput: true)),
        ]// Explicitly specify a list of widgets
    );
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