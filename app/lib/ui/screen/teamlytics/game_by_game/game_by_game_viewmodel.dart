import 'package:flutter/material.dart';
import 'package:poke_showstats/data/services/pokemon_resource_service.dart';

import '../../../../data/models/replay.dart';
import '../teamlytics_viewmodel.dart';

class GameByGameViewModel  {

  final Map<Replay, NoteEditingContext> _replayNoteEditingContextMap = {};
  final TeamlyticsViewModel _teamlyticsViewModel;
  PokemonResourceService get pokemonResourceService => _teamlyticsViewModel.pokemonResourceService;

  GameByGameViewModel({required TeamlyticsViewModel teamlyticsViewModel}) : _teamlyticsViewModel = teamlyticsViewModel;

  List<List<Replay>> get filteredMatches => _teamlyticsViewModel.filteredMatches;

  NoteEditingContext getEditingContext(Replay replay) => _replayNoteEditingContextMap.putIfAbsent(replay, () => NoteEditingContext());

  void saveNotes(Replay replay, NoteEditingContext context) {
    replay.notes = context.controller?.text;
    _teamlyticsViewModel.storeSave();
    context.view();
  }

  void dispose() {
    for (NoteEditingContext context in _replayNoteEditingContextMap.values) {
      context.dispose();
    }
  }
}

class NoteEditingContext extends ChangeNotifier {
  TextEditingController? _controller;
  TextEditingController? get controller => _controller;

  NoteEditingContext();

  void edit({String? initialValue}) {
    _controller = TextEditingController(text: initialValue);
    notifyListeners();
  }

  void view() {
    _controller = null;
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}