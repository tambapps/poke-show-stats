import 'dart:convert';

import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_image_service.dart';

class ReplayEntriesViewModel extends ChangeNotifier {

  ReplayEntriesViewModel({required this.pokemonImageService, required this.replayParser});

  final PokemonImageService pokemonImageService;
  final SdReplayParser replayParser;
  final TextEditingController addReplayURIController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;


  void loadReplay(HomeViewModel homeViewModel) {
    if (loading) return;
    String input = addReplayURIController.text.trim();
    addReplayURIController.clear();
    _setLoading(true);
    _fetchReplay(input)
        .then((replay) => homeViewModel.addReplay(replay))
        .catchError((error) {
      Logger.root.log(Level.WARNING, "Couldn't fetch replay", error=error);
      _setLoading(false);
      String errorMessage;
      if (error is FormatException) {
        errorMessage = "Invalid URI";
      } else {
        errorMessage = error.message;
      }
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    })
        .then((_) => _setLoading(false));
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
    Logger.root.log(Level.WARNING, "${data} ${uri}");
    return Replay(uri: uri, data: replayData);
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
}
