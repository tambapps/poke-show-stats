import 'package:app2/data/services/pokemon_resource_service.dart';
import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../../core/widgets/replay_filters.dart';
import '../home_viewmodel.dart';
import 'dart:developer' as developer;


class GameByGameViewModel extends ChangeNotifier {

  GameByGameViewModel({
    required this.homeViewModel,
    required this.pokemonResourceService
  }): filtersViewModel = ReplayFiltersViewModel(pokemonResourceService: pokemonResourceService) {
    filteredReplays = homeViewModel.replays;
  }
  final HomeViewModel homeViewModel;
  final ReplayFiltersViewModel filtersViewModel;
  final PokemonResourceService pokemonResourceService;
  late List<Replay> filteredReplays;

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

  @override
  void dispose() {
    filtersViewModel.dispose();
    super.dispose();
  }
}

class NoteEditingContext {
  final controller = TextEditingController();
  NoteEditingContext(String initialValue) {
    controller.text = initialValue;
  }

  void dispose() => controller.dispose();
}