import 'dart:collection';

import 'package:app2/data/services/pokeapi.dart';
import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../core/dialogs.dart';
import '../home_viewmodel.dart';

class HomeConfigViewModel extends ChangeNotifier {

  HomeConfigViewModel({required this.homeViewModel,
    required this.pokepasteParser, required this.pokeApi}) {
    if (homeViewModel.pokepaste != null) {
      _loadPokepasteMoves(homeViewModel.pokepaste!);
    }
  }

  // home view model properties
  List<String> get sdNames => homeViewModel.sdNames;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  PokemonImageService get pokemonImageService => homeViewModel.pokemonImageService;

  final HomeViewModel homeViewModel;
  final PokepasteParser pokepasteParser;
  final PokeApi pokeApi;
  final TextEditingController sdNameController = TextEditingController();
  final TextEditingController pokepasteController = TextEditingController();

  Map<String, Move> _pokemonMoves = {};
  Map<String, Move> get pokemonMoves => _pokemonMoves;

  // TODO use me
  bool _loading = false;
  bool get loading => _loading;

  void loadPokepaste() async {
    String input = pokepasteController.text.trim();
    _setLoading(true);
    Pokepaste pokepaste;
    try {
      pokepaste = pokepasteParser.parse(input);
    } on PokepasteParsingException catch(e) {
      errorMessage('This is not a pokepaste URL');
      return;
    }
    if (pokepaste.pokemons.isEmpty) {
      errorMessage('Pokepaste does not have any pokemon');
    }
    pokepasteController.clear();
    homeViewModel.pokepaste = pokepaste;
    _setLoading(false);
  }

  void _loadPokepasteMoves(Pokepaste pokepaste) {
    Set<String> moves = HashSet();
    for (Pokemon pokemon in pokepaste.pokemons) {
      moves.addAll(pokemon.moves);
    }
    for (String moveName in moves) {
      pokeApi.getMove(moveName).then((move) {
        if (move != null) {
          // need to re instantiate in order for Flutter to detect changes
          _pokemonMoves = Map.from(_pokemonMoves)..[moveName] = move;
          notifyListeners();
        }
      });
    }
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void errorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );  }

  void addSdNameDialog(BuildContext context, AppLocalization localization) {
    showTextInputDialog(
        context,
        title: localization.addSdName,
        hint: localization.enterSdName,
        confirmButtonText: localization.add,
        localization: localization,
        validator: (text) => text.trim().isNotEmpty && text.length <= 18,
        onSuccess: (sdName) => homeViewModel.addSdName(sdName)
    );
  }
  void removePokepaste() {
    homeViewModel.pokepaste = null;
  }

  void removeSdName(String sdName) => homeViewModel.removeSdName(sdName);

  void addSdName(String sdName) => homeViewModel.addSdName(sdName);
}