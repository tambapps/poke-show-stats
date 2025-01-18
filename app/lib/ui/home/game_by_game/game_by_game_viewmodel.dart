import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../home_viewmodel.dart';
import 'dart:developer' as developer;


typedef ReplayPredicate = bool Function(Replay);

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
  int _pokemonFilterTabIndex = 0;
  int get pokemonFilterTabIndex => _pokemonFilterTabIndex;

  final _Filters _filters = _Filters();


  TextEditingController get minEloController => _filters.minEloController;
  TextEditingController get maxEloController => _filters.maxEloController;

  PokemonFilters getPokemonFilters(int index) => _filters.pokemons[index];

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

  void applyFilters() {
    ReplayPredicate? predicate = _filters.getPredicate();
    if (predicate == null) {
      developer.log("No filters was applied");
      filteredReplays = homeViewModel.replays.toList();
    } else {
      filteredReplays = homeViewModel.replays.where(predicate).toList();
      developer.log("Got ${filteredReplays.length} replay matches out of ${homeViewModel.replays.length} replays");
    }
    notifyListeners();
  }

  void clearFilters() {
    _filters.clear();
  }
}

class NoteEditingContext {
  final controller = TextEditingController();
  NoteEditingContext(String initialValue) {
    controller.text = initialValue;
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
}

class PokemonFilters {
  final pokemonNameController = TextEditingController();
  final itemController = TextEditingController();
  final abilityController = TextEditingController();
  final teraTypeController = TextEditingController();
  final moveControllers = List.generate(4, (_) => TextEditingController());

  void clear() {
    pokemonNameController.clear();
    itemController.clear();
    abilityController.clear();
    teraTypeController.clear();
    for (TextEditingController moveController in moveControllers) {
      moveController.clear();
    }
  }
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
}