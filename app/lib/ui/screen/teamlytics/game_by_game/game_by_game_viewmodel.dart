import '../../../../data/services/pokemon_resource_service.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/replay.dart';
import '../teamlytics_viewmodel.dart';


class GameByGameViewModel extends ChangeNotifier {

  GameByGameViewModel({
    required this.homeViewModel,
    required this.pokemonResourceService,
  });

  final TeamlyticsViewModel homeViewModel;
  final PokemonResourceService pokemonResourceService;
  List<Replay> get filteredReplays => homeViewModel.filteredReplays;

  void editNote(Map<Replay, NoteEditingContext> replayNoteEditingContextMap, Replay replay) {
    replayNoteEditingContextMap[replay] = NoteEditingContext(replay.notes ?? "");
    notifyListeners();
  }

  void saveNotes(Map<Replay, NoteEditingContext> replayNoteEditingContextMap, Replay replay, String notes) {
    replay.notes = notes;
    NoteEditingContext? context = replayNoteEditingContextMap.remove(replay);
    context?.dispose();
    homeViewModel.storeSave();
    notifyListeners();
  }
}

class NoteEditingContext {
  final controller = TextEditingController();
  NoteEditingContext(String initialValue) {
    controller.text = initialValue;
  }

  void dispose() => controller.dispose();
}