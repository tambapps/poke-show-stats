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

}
