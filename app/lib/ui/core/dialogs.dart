


import 'package:flutter/material.dart';

import 'localization/applocalization.dart';

// a problem with that is that we can't display validation error message
Future<void> showTextInputDialog(
    BuildContext context,
    {
      required String title,
      required String hint,
      required AppLocalization localization,
      required TextEditingController textFieldController,
      required void Function(String) onSuccess,
      bool Function(String)? validator,
      String? confirmButtonText,
    }) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textFieldController,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(localization.cancel, style: TextStyle(color: Colors.red),)),
            TextButton(onPressed: () {
              final value = textFieldController.text;
              if (validator == null || validator(value)) {
                Navigator.pop(context);
                onSuccess(value);
              }
            }, child: Text(confirmButtonText ?? localization.ok))
          ],
        );
      });
}