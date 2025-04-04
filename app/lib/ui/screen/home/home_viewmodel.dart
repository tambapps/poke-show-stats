import 'package:flutter/material.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../../../data/services/save_service.dart';
import '../../../data/models/teamlytic.dart';

class HomeViewModel {

  final PokemonResourceService pokemonResourceService;
  final SaveService saveService;

  final ValueNotifier<List<TeamlyticPreview>> saves = ValueNotifier([]);
  final ValueNotifier<bool> loading = ValueNotifier(false);

  HomeViewModel({required this.pokemonResourceService, required this.saveService}) {
    loadSaves();
  }


  Future<void> loadSaves() async {
    loading.value = true;
    final fetchedSaves = await saveService.listSaves();
    fetchedSaves.sort((a, b) => - a.lastUpdatedAt.compareTo(b.lastUpdatedAt));
    saves.value = fetchedSaves;
    loading.value = false;
  }

  Future<void> deleteSave(TeamlyticPreview save) async {
    await saveService.deleteSave(save.saveName);
    await loadSaves();
  }

  Future<Teamlytic> createSave(String saveName) async {
    // will create a new one if it didn't existed
    final teamlytic = await saveService.loadSave(saveName);
    // make sure it is stored so that when we go back to home screen we see this save
    await saveService.storeSave(teamlytic);
    saves.value = [TeamlyticPreview.from(teamlytic), ...saves.value];
    return teamlytic;
  }

  Future<Teamlytic> createSaveFromSample(String sampleName) async {
    final teamlytic = await saveService.loadSample(sampleName);
    String saveName = sampleName;
    while (saves.value.any((s) => s.saveName == saveName)) {
      saveName = "Copy of $saveName";
    }
    teamlytic.saveName = saveName;
    await saveService.storeSave(teamlytic);
    saves.value = [TeamlyticPreview.from(teamlytic), ...saves.value];
    return teamlytic;
  }

  Future<void> changeName(String newName, TeamlyticPreview save) async {
    final teamlytic = await saveService.loadSave(save.saveName);
    await saveService.deleteSave(teamlytic.saveName);
    teamlytic.saveName = newName;
    await saveService.storeSave(teamlytic);
    await loadSaves();
  }

  Future<void> importSave(String saveJson) async {
    final teamlytic = await saveService.importSave(saveJson);
    saves.value = [TeamlyticPreview.from(teamlytic), ...saves.value];
  }
}
