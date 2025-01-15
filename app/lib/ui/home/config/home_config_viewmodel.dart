import 'package:app2/data/services/pokeapi.dart';
import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../core/dialogs.dart';
import '../home_viewmodel.dart';

class HomeConfigViewModel extends ChangeNotifier {

  HomeConfigViewModel({required this.homeViewModel, required this.pokepasteParser});

  // home view model properties
  List<String> get sdNames => homeViewModel.sdNames;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  Map<String, Move> get pokemonMoves => homeViewModel.pokemonMoves;
  PokemonImageService get pokemonImageService => homeViewModel.pokemonImageService;

  final HomeViewModel homeViewModel;
  final PokepasteParser pokepasteParser;
  final TextEditingController sdNameController = TextEditingController();
  final TextEditingController pokepasteController = TextEditingController();

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