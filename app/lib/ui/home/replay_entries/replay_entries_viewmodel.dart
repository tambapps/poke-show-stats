import 'dart:convert';

import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_image_service.dart';

class ReplayEntriesViewModel extends ChangeNotifier {

  ReplayEntriesViewModel({
    required this.replayParser,
    required this.homeViewModel});

  PokemonImageService get pokemonImageService => homeViewModel.pokemonImageService;
  List<Replay> get replays => homeViewModel.replays;
  List<String> get sdNames => homeViewModel.sdNames;

  final SdReplayParser replayParser;
  final HomeViewModel homeViewModel;
  final TextEditingController addReplayURIController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  void loadReplay() {
    if (loading) return;
    String input = addReplayURIController.text.trim();
    if (replays.any((replay) => replay.uri.toString().replaceFirst('.json', '') == input.replaceFirst('.json', ''))) {
      _errorToast("Duplicate entry");
      return;
    }
    addReplayURIController.clear();
    _setLoading(true);
    _fetchReplay(input)
        .then((replay) => homeViewModel.addReplay(replay))
        .catchError((error) {
      _setLoading(false);
      String errorMessage;
      if (error is FormatException) {
        errorMessage = "Invalid URI";
      } else {
        errorMessage = error.message;
      }
      _errorToast(errorMessage);
    })
        .then((_) => _setLoading(false));
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

  void openLink(String link) async {
    final Uri uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens browser or Chrome Tabs on mobile
        webOnlyWindowName: '_blank',         // Opens a new tab on the web
      );
    } else {
      throw "Could not launch $link";
    }
  }

  Future<Replay> _fetchReplay(String input) async {
    Uri uri = Uri.parse(input.endsWith('.json') ? input : "$input.json");
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Error while fetching replay (response code ${response.statusCode})");
    }
    final data = jsonDecode(response.body);
    SdReplayData replayData = replayParser.parse(data);
    return Replay(uri: uri, data: replayData);
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void removeReplay(Replay replay) => homeViewModel.removeReplay(replay);

  getWinStatus(Replay replay) {
    if (sdNames.isEmpty) return 0;
    return sdNames.contains(replay.data.winnerPlayer.name) ? 1 : -1;
  }

  PlayerData getOpposingPlayer(Replay replay) {
    if (sdNames.isEmpty) {
      return replay.data.player1;
    }
    return sdNames.contains(replay.data.player2.name) ? replay.data.player1 : replay.data.player2;
  }
}
