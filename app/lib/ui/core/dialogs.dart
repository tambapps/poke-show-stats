


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_showstats/data/services/pokemon_resource_service.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import 'localization/applocalization.dart';
import 'widgets/pokepaste_widget.dart';
import 'widgets/text_input_dialog.dart';

// a problem with that is that we can't display validation error message
Future<void> showTextInputDialog(
    BuildContext context,
    {
      required String title,
      required String hint,
      required AppLocalization localization,
      required bool Function(String) onSuccess,
      String? Function(String)? validator,
      String? confirmButtonText,
      String? initialValue,
      int? maxLines = 1
    }) {
  return showDialog(
      context: context,
      builder: (context) {
        return TextInputDialog(
            title: title,
            hint: hint,
            onSuccess: onSuccess,
            validator: validator,
            confirmButtonText: confirmButtonText,
            initialValue: initialValue,
            maxLines: maxLines
        );
      });
}


void showTeamSheetDialog({required BuildContext context, required String title,
  required Pokepaste pokepaste, required PokemonResourceService pokemonResourceService}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: PokepasteWidget(pokepaste: pokepaste, pokemonResourceService: pokemonResourceService),),
          actions: [
            TextButton(onPressed: () {
              Clipboard.setData(ClipboardData(text: pokepaste.toString()));
              Navigator.pop(context);
            }, child: Text("Copy",)),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK",)),
            ],
        );
      });
}