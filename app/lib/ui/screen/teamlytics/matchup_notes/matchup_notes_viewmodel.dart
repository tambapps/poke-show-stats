// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:poke_showstats/data/models/matchup.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../../data/services/pokemon_resource_service.dart';
import '../teamlytics_viewmodel.dart';

class MatchUpNotesViewmodel {

  final PokemonResourceService pokemonResourceService;
  final TeamlyticsViewModel teamlyticsViewModel;
  final PokepasteParser pokepasteParser;
  final Map<MatchUp, MatchUpEditingContext> _editingContexts = {};

  MatchUpNotesViewmodel({required this.pokemonResourceService, required this.teamlyticsViewModel, required this.pokepasteParser});

  void createMatchUp(String name) {
    final matchUp = MatchUp(name: name, pokepaste: null, notes: null);
    teamlyticsViewModel.addMatchUp(matchUp);
    getContext(matchUp).edit(matchUp: matchUp);
  }

  Pokepaste? parsePokepaste(String text) {
    try {
      return pokepasteParser.parse(text);
    } on PokepasteParsingException {
      return null;
    }
  }

  String? validatePokepaste(String text) {
    try {
      pokepasteParser.parse(text);
      return null;
    } on PokepasteParsingException catch (e) {
      return e.message;
    }
  }

  MatchUpEditingContext getContext(MatchUp m) => _editingContexts.putIfAbsent(m, () => MatchUpEditingContext());

  void dispose() {
    for (final context in _editingContexts.values) {
      context.dispose();
    }
  }

  void updatePokepaste(MatchUp matchUp, Pokepaste pokepaste) {
    matchUp.pokepaste = pokepaste;
    teamlyticsViewModel.matchUpsNotifiers.notifyListeners();
    teamlyticsViewModel.storeSave();
  }

  void updateMatchUp(MatchUp matchUp, String name, String notes) {
    matchUp.name = name;
    matchUp.notes = notes;
    teamlyticsViewModel.matchUpsNotifiers.notifyListeners();
    teamlyticsViewModel.storeSave();
    getContext(matchUp).view();
  }

  void deleteMatchUp(MatchUp matchUp) {
    teamlyticsViewModel.removeMatchUp(matchUp);
    _editingContexts.remove(matchUp);
  }
}

class MatchUpEditingContext extends ChangeNotifier {
  TextEditingController? _nameController;
  TextEditingController get nameController => _nameController!;
  TextEditingController? _notesController;
  TextEditingController get notesController => _notesController!;

  bool get isEditing => _nameController != null;

  MatchUpEditingContext();

  void edit({MatchUp? matchUp}) {
    _nameController = TextEditingController(text: matchUp?.name);
    _notesController = TextEditingController(text: matchUp?.notes);
    notifyListeners();
  }

  void view() {
    _disposeControllers();
    notifyListeners();
  }

  void _disposeControllers() {
    _nameController?.dispose();
    _notesController?.dispose();
    _nameController = null;
    _notesController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}