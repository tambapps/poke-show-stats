import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../../core/widgets/replay_filters.dart';
import '../home_viewmodel.dart';
import 'dart:developer' as developer;


class GameByGameViewModel extends ChangeNotifier {

  GameByGameViewModel({
    required this.homeViewModel,
    required this.pokemonImageService
  }) {
    filteredReplays = homeViewModel.replays;
  }
  final HomeViewModel homeViewModel;
  final PokemonImageService pokemonImageService;
  late List<Replay> filteredReplays;
  Map<Replay, NoteEditingContext> replayNoteEditingContextMap = {};

  void editNote(Replay replay) {
    replayNoteEditingContextMap[replay] = NoteEditingContext(replay.notes ?? "");
    notifyListeners();
  }

  void saveNotes(Replay replay, String notes) {
    replay.notes = notes;
    replayNoteEditingContextMap.remove(replay);
    homeViewModel.storeSave();
    notifyListeners();
  }

  void applyFilters(ReplayPredicate? predicate) {
    if (predicate == null) {
      developer.log("No filters was applied");
      filteredReplays = homeViewModel.replays.toList();
    } else {
      filteredReplays = homeViewModel.replays.where(predicate).toList();
      developer.log("Got ${filteredReplays.length} replay matches out of ${homeViewModel.replays.length} replays");
    }
    notifyListeners();
  }
}

class NoteEditingContext {
  final controller = TextEditingController();
  NoteEditingContext(String initialValue) {
    controller.text = initialValue;
  }
}