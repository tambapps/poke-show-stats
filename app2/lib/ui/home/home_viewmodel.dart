import 'package:flutter/foundation.dart';

import '../../data/models/replay.dart';
import '../../data/services/pokemon_image_service.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({required this.pokemonImageService});

  final PokemonImageService pokemonImageService;

  final List<String> sdNames = [];
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
}
