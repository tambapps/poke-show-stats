import 'package:app2/data/models/teamlytic.dart';
import 'package:flutter/material.dart';

import '../../data/services/pokemon_resource_service.dart';
import '../../data/services/save_service.dart';

class HomeViewModel extends ChangeNotifier {

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  List<TeamlyticPreview> _saves = [];
  List<TeamlyticPreview> get saves => _saves;

  HomeViewModel({required this.pokemonResourceService, required this.saveService}) {
    _loadSaves();
  }


  void _loadSaves() async {
    List<TeamlyticPreview> saves = await saveService.listSaves();
    _saves = saves;
    notifyListeners();
  }
}
