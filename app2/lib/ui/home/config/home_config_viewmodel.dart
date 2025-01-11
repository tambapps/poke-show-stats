import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../home_viewmodel.dart';
import 'package:http/http.dart' as http;

class HomeConfigViewModel extends ChangeNotifier {

  HomeConfigViewModel({required this.homeViewModel});

  final HomeViewModel homeViewModel;
  final TextEditingController sdNameController = TextEditingController();
  final TextEditingController pokepasteController = TextEditingController();

  // TODO use me
  bool _loading = false;
  bool get loading => _loading;

  void loadPokepaste() async {
    String input = pokepasteController.text.trim();
    if (!input.startsWith('https://pokepast.es/')) {
      errorMessage('This is not a pokepaste URL');
      return;
    }
    Uri uri;
    try {
      uri = Uri.parse(input);
    }  on FormatException {
      errorMessage("Invalid URL");
      return;
    }

    _setLoading(true);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      errorMessage("Error while fetching pokepaste (response code ${response.statusCode})");
      return;
    }
    print(response.body);
    pokepasteController.clear();
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
}