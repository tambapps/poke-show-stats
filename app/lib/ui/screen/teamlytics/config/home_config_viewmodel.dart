import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:poke_showstats/data/services/save_service.dart';

import '../../../../data/services/pokemon_resource_service.dart';
import '../../../core/localization/applocalization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import '../../../core/dialogs.dart';
import '../teamlytics_viewmodel.dart';

class HomeConfigViewModel {

  HomeConfigViewModel({required this.teamlyticsViewmodel, required this.pokepasteParser, required this.saveService});

  // home view model properties
  List<String> get sdNames => teamlyticsViewmodel.sdNames;
  Pokepaste? get pokepaste => teamlyticsViewmodel.pokepaste;
  PokemonResourceService get pokemonResourceService => teamlyticsViewmodel.pokemonResourceService;
  String get saveName => teamlyticsViewmodel.saveName;

  final TeamlyticsViewModel teamlyticsViewmodel;
  final PokepasteParser pokepasteParser;
  final SaveService saveService;

  ValueNotifier<bool> pokepasteLoadingNotifier = ValueNotifier(false);

  void loadPokepaste(TextEditingController pokepasteController) async {
    pokepasteLoadingNotifier.value = true;
    String input = pokepasteController.text.trim();
    Pokepaste pokepaste;
    try {
      pokepaste = pokepasteParser.parse(input);
    } on PokepasteParsingException {
      errorMessage('This is not a valid pokepaste');
      return;
    }
    if (pokepaste.pokemons.isEmpty) {
      errorMessage('Pokepaste does not have any pokemon');
    }
    teamlyticsViewmodel.pokepaste = pokepaste;
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
          teamlyticsViewmodel.addSdName(sdName);
          return true;
        }
    );
  }
  void removePokepaste() {
    teamlyticsViewmodel.pokepaste = null;
  }

  void removeSdName(String sdName) => teamlyticsViewmodel.removeSdName(sdName);

  void addSdName(String sdName) => teamlyticsViewmodel.addSdName(sdName);

  void exportSave() async {
    String? saveJson = await saveService.loadSaveJson(saveName);
    if (saveJson == null) {
      Fluttertoast.showToast(
        msg: "Couldn't export save",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    // only works for web. In android/ios it saves the file in an application-specific directory instead of the Downloads folder
    await FileSaver.instance.saveFile(name: saveName, ext: "json", bytes: utf8.encode(saveJson));
  }
}