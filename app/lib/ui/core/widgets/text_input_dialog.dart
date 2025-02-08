

import 'package:flutter/material.dart';

import '../localization/applocalization.dart';

typedef Validator = String? Function(String);

class TextInputDialog extends StatefulWidget {

  final String title;
  final String? hint;
  final String? confirmButtonText;
  final String? initialValue;
  final bool Function(String) onSuccess;
  final Validator? validator;
  const TextInputDialog({super.key, this.hint, required this.onSuccess, required this.validator, required this.title, this.confirmButtonText, this.initialValue});

  @override
  State<StatefulWidget> createState() => _TextInputDialogState();

}

class _TextInputDialogState extends State<TextInputDialog> {

  late TextEditingController _textFieldController;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    AppLocalization localization = AppLocalization.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(hintText: widget.hint, errorText: _errorText, errorStyle: TextStyle(color: Colors.red)),
        onChanged: (text) => setState(() => _errorText = null),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localization.cancel,)),
        TextButton(onPressed: () {
          final value = _textFieldController.text;
          String? error;
          if (widget.validator != null) {
            error = widget.validator!(value);
            setState(() {
              _errorText = error;
            });
          }
          if (error == null && widget.onSuccess(value)) {
            Navigator.pop(context);
          }
        }, child: Text(widget.confirmButtonText ?? localization.ok))
      ],
    );
  }


  @override
  void initState() {
    _textFieldController = TextEditingController();
    if (widget.initialValue != null) {
      _textFieldController.text = widget.initialValue!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}