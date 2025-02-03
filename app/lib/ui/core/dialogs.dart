


import 'package:flutter/material.dart';

import 'localization/applocalization.dart';
import 'widgets/text_input_dialog.dart';

// a problem with that is that we can't display validation error message
Future<void> showTextInputDialog(
    BuildContext context,
    {
      required String title,
      required String hint,
      required AppLocalization localization,
      required TextEditingController textFieldController,
      required bool Function(String) onSuccess,
      String? Function(String)? validator,
      String? confirmButtonText,
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
        );
      });
}