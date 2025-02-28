import 'package:pokemon_core/pokemon_core.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../localization/applocalization.dart';
import '../themes/dimens.dart';
import '../widgets.dart';
import '../widgets/auto_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/replay.dart';
import 'controlled_autocomplete.dart';

typedef ReplayPredicate = bool Function(Replay);
typedef PokemonPredicate = bool Function(Pokemon);

class ReplayFiltersWidget extends StatefulWidget {
  final ReplayFiltersViewModel viewModel;
  final void Function(ReplayPredicate?) applyFilters;
  final bool isMobile;
  final int totalReplaysCount;
  final int matchedReplaysCount;

  const ReplayFiltersWidget({super.key, required this.viewModel, required this.applyFilters, required this.isMobile, required this.totalReplaysCount, required this.matchedReplaysCount});

  @override
  State createState() => isMobile ? _MobileReplayFiltersWidgetState() : _DesktopReplayFiltersWidgetState();
}

// doesn't extend AbstractViewModelState because the parent component should be responsible of disposing this component's viewModel
abstract class _AbstractReplayFiltersWidgetState extends AbstractState<ReplayFiltersWidget> with TickerProviderStateMixin {

  late TabController _tabController;
  late ExpansionTileController _expansionTileController;
  ReplayFiltersViewModel get _viewModel => widget.viewModel;
  void Function(ReplayPredicate?) get applyFilters => widget.applyFilters;

  ReplayFilters get _filters => _viewModel.filters;

  @override
  void initState() {
    super.initState();
    // The `vsync: this` ensures the TabController is synchronized with the screen's refresh rate
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() => _viewModel.selectedPokemonFilterIndex.value = _tabController.index);
    _expansionTileController = ExpansionTileController();
  }

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.replayFiltersContainerPadding, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey,
              width: 2.0
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ExpansionTile(
          maintainState: true,
          controller: _expansionTileController,
          title: Text("Replay filters"),
            subtitle: Text(
                widget.totalReplaysCount != widget.matchedReplaysCount ?
                "Matched ${widget.matchedReplaysCount} replays out of ${widget.totalReplaysCount}"
                    : "${widget.totalReplaysCount} replays"),
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: dimens.pokemonFiltersHorizontalSpacing),
              child: eloFiltersWidget(context, localization, dimens, theme),),
            const SizedBox(height: 16.0,),
            Text("Opponent's team", style: theme.textTheme.titleMedium, ),
            const SizedBox(height: 16.0,),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: TabBar(
          controller: _tabController,
          isScrollable: widget.isMobile,
          tabs: Iterable.generate(6, (index) => index).map((index) =>
              Padding(padding: EdgeInsets.only(bottom: 4.0),
                child: ValueListenableBuilder(
                    valueListenable: _viewModel.selectedPokemonFilterIndex,
                    builder: (context, selectedPokemonFilterIndex, _) => Text("Pokemon ${index + 1}", style: theme.textTheme.titleMedium?.copyWith(color: index != selectedPokemonFilterIndex ? Colors.grey : null),)),)).toList(),
        ),),
            ConstrainedBox(constraints: BoxConstraints(maxHeight: dimens.pokemonFiltersTabViewHeight),
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TabBarView(controller: _tabController, children: List.generate(6, (index) => _pokemonFilterWidget(context, localization, dimens, theme, index))),),),

            Text("Your selection", style: theme.textTheme.titleMedium, ),
            const SizedBox(height: 16.0,),
            yourSelectionWidget(context, localization, dimens, theme),
            const SizedBox(height: 32.0,),
            Align(alignment: Alignment.bottomRight,
              child: Padding(padding: EdgeInsets.symmetric(horizontal: dimens.pokemonFiltersHorizontalSpacing, vertical: 8.0),
                child: ValueListenableBuilder(
                    valueListenable: _viewModel.dirty, builder: (context, dirty, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(onPressed: () {
                      _viewModel.dirty.value = true;
                      _filters.clear();
                    }, child: Text("Clear")), const SizedBox(width: 16.0,),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: dirty ? const BorderSide(color: Colors.orange) : null,
                        ),
                        onPressed: () {
                          applyFilters(_filters.getPredicate());
                          _viewModel.dirty.value = false;
                          _expansionTileController.collapse();
                        },
                        child: Text("Apply"))],
                )
                ),),),
            const SizedBox(height: 8.0,),
          ],
        ),
      ),
    );
  }

  Widget yourSelectionWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {

    return AutoGridView(
      columnsCount: dimens.pokemonFiltersColumnsCount,
      verticalCellSpacing: 8.0,
      horizontalCellSpacing: dimens.pokemonFiltersHorizontalSpacing,
      rowCrossAxisAlignment: CrossAxisAlignment.start,
      children:  List.generate(4, (index) {
        final PokemonSelectionFilter filter = _filters.selectionFilters[index];
        return Padding(padding: EdgeInsets.symmetric(horizontal: dimens.pokemonFiltersHorizontalSpacing),
          child: selectionFilterWidget(context, localization, dimens, theme, filter, leadOption: index < 2),);
      }),  // Explicitly specify a list of widgets
    );
  }

  Widget selectionFilterWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, PokemonSelectionFilter filter, {bool leadOption = false}) {
    if (leadOption) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pokemonNameTextInput(controller: filter.pokemonNameController),
          ValueListenableBuilder(valueListenable: filter.asLead,
              builder: (context, asLead, _) => CheckboxListTile(
                title: Text("as lead", textAlign: TextAlign.center,),
                value: asLead,
                onChanged: (newValue) {
                  filter.asLead.value = newValue ?? false;
                  _viewModel.dirty.value = true;
                },
                controlAffinity: ListTileControlAffinity.leading,
              )
          )
        ],);
    } else {
      return pokemonNameTextInput(controller: filter.pokemonNameController);
    }
  }

  Widget pokemonNameTextInput({String labelText = "Pokemon", required TextEditingController controller}) => autoCompleteMapTextInput(labelText: labelText, suggestions: _viewModel.pokemonResourceService.pokemonMappings, controller: controller);

  Widget eloFiltersWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
  Widget _pokemonFilterWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, int index) {
    final pokemonFilters = _filters.opposingTeamPokemons[index];

    // computing it here to avoid computing it 4 times
    List<MapEntry<dynamic, dynamic>> moveSuggestionEntries = _viewModel.pokemonResourceService.pokemonMoves.entries.toList();

    return AutoGridView(
      columnsCount: dimens.pokemonFiltersColumnsCount,
      verticalCellSpacing: 8.0,
      horizontalCellSpacing: dimens.pokemonFiltersHorizontalSpacing,
      children: [
        pokemonNameTextInput(controller: pokemonFilters.pokemonNameController),
        autoCompleteMapTextInput(labelText: "Item", suggestions: _viewModel.pokemonResourceService.itemMappings, controller: pokemonFilters.itemController),
        autoCompleteMapTextInput(labelText: "Ability", suggestions: _viewModel.pokemonResourceService.abilities, controller: pokemonFilters.abilityController),
        autoCompleteStringTextInput(labelText: "Tera Type", suggestions: _viewModel.pokemonResourceService.teraTypes, controller: pokemonFilters.teraTypeController),
        ...List.generate(4, (index) => autoCompleteListTextInput(labelText: "Move ${index + 1}", suggestions: moveSuggestionEntries, controller: pokemonFilters.moveControllers[index]))
      ],  // Explicitly specify a list of widgets
    );
  }

  Widget autoCompleteStringTextInput({required String labelText, required List<String> suggestions, required TextEditingController controller}) {
    return autoCompleteTextInput(labelText: labelText, suggestions: suggestions, controller: controller, displayStringForOption: (s) => _displayedName(s.replaceAll('-', ' ')));
  }

  Widget autoCompleteMapTextInput({required String labelText, required Map<dynamic, dynamic> suggestions, required TextEditingController controller}) {
    return autoCompleteListTextInput(labelText: labelText, suggestions: suggestions.entries.toList(), controller: controller);
  }

  Widget autoCompleteListTextInput({required String labelText, required List<MapEntry<dynamic, dynamic>> suggestions, required TextEditingController controller}) {
    return autoCompleteTextInput(labelText: labelText, suggestions: suggestions,
        controller: controller,
        displayStringForOption: (entry) => _displayedName(entry.key.replaceAll('-', ' ')),
        suggestionsMatcher: (textEditingValue, option) => Pokemon.normalize(option.key).contains(Pokemon.normalize(textEditingValue.text)));
  }

  Widget autoCompleteTextInput<T extends Object>({required String labelText,
    required List<T> suggestions, required TextEditingController controller,
    required String Function(T) displayStringForOption,
    SuggestionsMatcher<T>? suggestionsMatcher}) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: ControlledAutoComplete<T>(
        controller: controller,
        suggestions: suggestions,
        onSelected: (_) => _viewModel.dirty.value = true,
        displayStringForOption: displayStringForOption,
        suggestionsMatcher: suggestionsMatcher,
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (value) => onFieldSubmitted(),
            onChanged: (_) => _viewModel.dirty.value = true,
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
    super.dispose();
  }
}

class ReplayFiltersViewModel {

  ReplayFiltersViewModel({required this.pokemonResourceService, required this.filters});

  final PokemonResourceService pokemonResourceService;
  final ReplayFilters filters;

  ValueNotifier<bool> dirty = ValueNotifier(false);


  ValueNotifier<int> selectedPokemonFilterIndex = ValueNotifier(0);

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

class ReplayFilters {

  final TextEditingController minEloController = TextEditingController();
  final TextEditingController maxEloController = TextEditingController();

  final List<PokemonFilters> opposingTeamPokemons = List.generate(6, (_) => PokemonFilters());
  final List<PokemonSelectionFilter> selectionFilters = List.generate(4, (_) => PokemonSelectionFilter());

  ReplayPredicate? getPredicate() {
    List<ReplayPredicate> predicates = [];

    if (minEloController.text.trim().isNotEmpty) {
      final minElo = int.tryParse(minEloController.text.trim()) ?? 0;
      predicates.add((replay) => replay.opposingPlayer.beforeElo != null && replay.opposingPlayer.beforeElo! >= minElo);
    }
    if (maxEloController.text.trim().isNotEmpty) {
      final minElo = int.tryParse(maxEloController.text.trim()) ?? 0;
      predicates.add((replay) => replay.opposingPlayer.beforeElo != null && replay.opposingPlayer.beforeElo! <= minElo);
    }
    for (PokemonFilters pokemonFilters in opposingTeamPokemons) {
      ReplayPredicate? pokemonPredicate = pokemonFilters.getPredicate();
      if (pokemonPredicate != null) {
        predicates.add(pokemonPredicate);
      }
    }
    for (PokemonSelectionFilter selectionFilter in selectionFilters) {
      ReplayPredicate? pokemonPredicate = selectionFilter.getPredicate();
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
    for (PokemonFilters pokemonFilters in opposingTeamPokemons) {
      pokemonFilters.clear();
    }
    for (PokemonSelectionFilter selectionFilter in selectionFilters) {
      selectionFilter.clear();
    }
  }

  void dispose() {
    minEloController.dispose();
    maxEloController.dispose();
    for (PokemonFilters pokemonFilters in opposingTeamPokemons) {
      pokemonFilters.dispose();
    }
    for (PokemonSelectionFilter filter in selectionFilters) {
      filter.dispose();
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
    List<PokemonPredicate> predicates = [];
    if (itemController.text.trim().isNotEmpty) {
      final item = Pokemon.normalize(itemController.text.trim());
      predicates.add((pokemon) => item == Pokemon.normalizeNullable(pokemon.item));
    }
    if (abilityController.text.trim().isNotEmpty) {
      final ability = Pokemon.normalize(abilityController.text.trim());
      predicates.add((pokemon) => ability == Pokemon.normalize(pokemon.ability));
    }
    if (teraTypeController.text.trim().isNotEmpty) {
      final teraType = Pokemon.normalize(teraTypeController.text.trim());
      predicates.add((pokemon) => teraType == Pokemon.normalize(pokemon.teraType));
    }
    for (TextEditingController moveController in moveControllers) {
      if (moveController.text.trim().isNotEmpty) {
        final move = Pokemon.normalize(moveController.text.trim());
        predicates.add((pokemon) => pokemon.moves.any((pokemonMove) => move == Pokemon.normalize(pokemonMove)));
      }
    }

    // doing it on last because we will check if other filters were specified
    if (pokemonNameController.text.trim().isNotEmpty) {
      final pokemonName = Pokemon.normalize(pokemonNameController.text.trim());
      if (predicates.isEmpty) {
        // returning here because some games might not have OTS and we just want a match on pokemon name which can happen on opposing player team
        return (replay) => replay.opposingPlayer.team.any((pName) => Pokemon.nameMatch(pokemonName, pName));
      }
      predicates.add((pokemon) => Pokemon.nameMatch(pokemon.name, pokemonName));
    }

    return predicates.isNotEmpty ?
        (replay) => replay.opposingPlayer.pokepaste != null && replay.opposingPlayer.pokepaste!.pokemons.any((pokemon) => predicates.every((predicate) => predicate(pokemon)))
        : null;
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

class PokemonSelectionFilter {
  final pokemonNameController = TextEditingController();
  final ValueNotifier<bool> asLead = ValueNotifier(false);

  void dispose() => pokemonNameController.dispose();

  ReplayPredicate? getPredicate() {
    final String pokemon = pokemonNameController.text.trim();
    if (pokemonNameController.text.trim().isEmpty) {
      return null;
    }
    if (asLead.value) {
      return (replay) => replay.otherPlayer.leads.any((pokemonName) => Pokemon.nameMatch(pokemon, pokemonName));
    } else {
      return (replay) => replay.otherPlayer.selection.any((pokemonName) => Pokemon.nameMatch(pokemon, pokemonName));
    }
  }

  void clear() {
    pokemonNameController.clear();
    asLead.value = false;
  }

}