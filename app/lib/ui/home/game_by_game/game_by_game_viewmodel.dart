import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../home_viewmodel.dart';

class GameByGameViewModel extends ChangeNotifier {
  GameByGameViewModel({
    required this.homeViewModel,
    required this.pokemonImageService
  });

  final HomeViewModel homeViewModel;
  final PokemonImageService pokemonImageService;
  List<Replay> get replays => homeViewModel.replays;
  Map<Replay, NoteEditingContext> replayNoteEditingContextMap = {};
  int _pokemonFilterTabIndex = 0;
  int get pokemonFilterTabIndex => _pokemonFilterTabIndex;

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

  void onPokemonFilterTabSelected(int index) => _pokemonFilterTabIndex = index;
}

class NoteEditingContext {
  final controller = TextEditingController();
  NoteEditingContext(String initialValue) {
    controller.text = initialValue;
  }
}
enum NoteConsultMode {
  EDIT, VIEW
}
