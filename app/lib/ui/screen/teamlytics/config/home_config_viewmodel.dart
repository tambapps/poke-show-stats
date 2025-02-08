import '../../../../data/services/pokemon_resource_service.dart';
import '../../../core/localization/applocalization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../../core/dialogs.dart';
import '../teamlytics_viewmodel.dart';

class HomeConfigViewModel {

  HomeConfigViewModel({required this.homeViewModel, required this.pokepasteParser});

  // home view model properties
  List<String> get sdNames => homeViewModel.sdNames;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  PokemonResourceService get pokemonResourceService => homeViewModel.pokemonResourceService;

  final TeamlyticsViewModel homeViewModel;
  final PokepasteParser pokepasteParser;

  ValueNotifier<bool> pokepasteLoadingNotifier = ValueNotifier(false);

  void loadPokepaste(TextEditingController pokepasteController) async {
    pokepasteLoadingNotifier.value = true;
    String input = pokepasteController.text.trim();
    Pokepaste pokepaste;
    try {
      pokepaste = pokepasteParser.parse(input);
    } on PokepasteParsingException catch(e) {
      errorMessage('This is not a valid pokepaste');
      return;
    }
    if (pokepaste.pokemons.isEmpty) {
      errorMessage('Pokepaste does not have any pokemon');
    }
    homeViewModel.pokepaste = pokepaste;
    pokepasteLoadingNotifier.value = false;
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
        validator: (text) => text.trim().isNotEmpty && text.length <= 18 ? null :  "Showdown name is not valid",
        onSuccess: (sdName) {
          homeViewModel.addSdName(sdName);
          return true;
        }
    );
  }
  void removePokepaste() {
    homeViewModel.pokepaste = null;
  }

  void removeSdName(String sdName) => homeViewModel.removeSdName(sdName);

  void addSdName(String sdName) => homeViewModel.addSdName(sdName);
}