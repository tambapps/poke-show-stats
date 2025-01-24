import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_image_service.dart';

class ReplayEntriesViewModel extends ChangeNotifier {

  ReplayEntriesViewModel({
    required this.replayParser,
    required this.homeViewModel});

  PokemonResourceService get pokemonImageService => homeViewModel.pokemonImageService;
  List<Replay> get replays => homeViewModel.replays;
  List<String> get sdNames => homeViewModel.sdNames;

  final SdReplayParser replayParser;
  final HomeViewModel homeViewModel;
  TextEditingController get addReplayURIController => homeViewModel.addReplayURIController;

  bool _loading = false;
  bool get loading => _loading;

  void loadReplays() async {
    if (loading) return;
    String text = addReplayURIController.text.trim();
    StringBuffer failedUrls = StringBuffer();
    _setLoading(true);
    for (String rawInput in text.split(RegExp(r'\s+'))) {
      String input = rawInput.trim();
      if (input.isEmpty) continue;
      if (!(await _loadReplay(input))) {
        failedUrls.writeln(input);
      }
    }
    _setLoading(false);
    addReplayURIController.text = failedUrls.toString().trim();
  }

  Future<bool> _loadReplay(String input) async {
    if (replays.any((replay) => replay.uri.toString().replaceFirst('.json', '') == input.replaceFirst('.json', ''))) {
      _errorToast("Duplicate entry");
      return false;
    }
    Uri uri;
    try {
      uri = Uri.parse(input.endsWith('.json') ? input : "$input.json");
    } on FormatException {
      _errorToast("Invalid URI");
      return false;
    }
    final SdReplayData replayData;
    try {
      replayData = await _fetchReplayData(uri);
    } on dynamic catch (e) {
      developer.log("Error while fetching replay $uri");
      _errorToast(e.message);
      return false;
    }
    homeViewModel.addReplay(uri, replayData);
    return true;
  }

  void _errorToast(String errorMessage) {
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<SdReplayData> _fetchReplayData(Uri uri) async {
    final response = await http.get(uri);
    if (response.statusCode == 404) {
      throw Exception("Replay was not found");
    }
    if (response.statusCode != 200) {
      throw Exception("Error while fetching replay (response code ${response.statusCode})");
    }
    final data = jsonDecode(response.body);
    return replayParser.parse(data);
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void removeReplay(Replay replay) => homeViewModel.removeReplay(replay);

}
