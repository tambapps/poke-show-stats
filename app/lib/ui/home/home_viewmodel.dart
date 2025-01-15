import 'package:app2/data/models/teamlytic.dart';
import 'package:app2/data/services/save_service.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../data/models/replay.dart';
import '../../data/services/pokemon_image_service.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({required this.pokemonImageService, required this.saveService});

  final PokemonImageService pokemonImageService;
  final SaveService saveService;
  Teamlytic _teamlytic = Teamlytic(saveName: '', sdNames: [], replays: [], pokepaste: null);
  // TODO hack for now as we cannot select multiple saves
  final String saveName = "default";

  List<Replay> get replays => _teamlytic.replays;
  List<String> get sdNames => _teamlytic.sdNames;
  Pokepaste? get pokepaste => _teamlytic.pokepaste;
  set pokepaste(Pokepaste? value) {
    _teamlytic.pokepaste = value;
    notifyListeners();
    _save();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    // don't need to notifyListeners() because the DefaultTabController handles its own state
    //  I am just listening to the changes of it
    _selectedIndex = index;
  }

  void addReplay(Replay replay) {
    _teamlytic.replays = [...replays, replay];
    notifyListeners();
    _save();
  }

  void removeReplay(Replay replay) {
    _teamlytic.replays = [...replays]..remove(replay);
    notifyListeners();
    _save();
  }

  void addSdName(String sdName) {
    if (!sdNames.contains(sdName)) {
      _teamlytic.sdNames = [...sdNames, sdName];
      notifyListeners();
      _save();
    }
  }

  void removeSdName(String sdName) {
    _teamlytic.sdNames = [...sdNames]..remove(sdName);
    notifyListeners();
    _save();
  }

  void _save() async => await saveService.storeSave(_teamlytic);

  void loadSave() async {
    _teamlytic = await saveService.loadSave(saveName);
    notifyListeners();
  }
}
