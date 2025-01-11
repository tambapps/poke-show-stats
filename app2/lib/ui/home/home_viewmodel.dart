import 'package:flutter/material.dart';
import '../../data/models/replay.dart';
import '../../data/services/pokemon_image_service.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({required this.pokemonImageService});

  final PokemonImageService pokemonImageService;

  final List<String> sdNames = ['blue fakinaway', 'jarmanvgc'];
  List<Replay> replays = [];
  String? pokepasteUrl;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    // don't need to notifyListeners() because the DefaultTabController handles its own state
    //  I am just listening to the changes of it
    _selectedIndex = index;
  }

  void addReplay(Replay replay) {
    replays.add(replay);
    notifyListeners();
  }

  void removeReplay(Replay replay) {
    replays.remove(replay);
    notifyListeners();
  }

  void addSdName(String sdName) {
    if (!sdNames.contains(sdName)) {
      sdNames.add(sdName);
      notifyListeners();
    }
  }

  void removeSdName(String sdName) {
    sdNames.remove(sdName);
    notifyListeners();
  }
}
