import 'package:flutter/material.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../../../data/services/save_service.dart';
import '../../../data/models/teamlytic.dart';

class HomeViewModel {

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  List<TeamlyticPreview> _saves = [];
  List<TeamlyticPreview> get saves => _saves;
  final ValueNotifier<bool> loading = ValueNotifier(false);

  HomeViewModel({required this.pokemonResourceService, required this.saveService}) {
    _loadSaves();
  }


  void _loadSaves() async {
    loading.value = true;
  //  notifyListeners();
    List<TeamlyticPreview> saves = await saveService.listSaves();
    _saves = saves;
    loading.value = false;
  //  notifyListeners();
  }

  void deleteSave(TeamlyticPreview save) {
    saveService.deleteSave(save.saveName);
    _saves = [..._saves]..removeWhere((s) => s.saveName == save.saveName);
//    notifyListeners();
  }
}
