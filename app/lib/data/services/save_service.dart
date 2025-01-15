import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app2/data/models/replay.dart';
import 'package:app2/data/models/teamlytic.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

abstract class SaveStorage {

  Future<List<String>> listSaveNames();
  Future<String?> loadSaveJson(String saveName);
  Future<bool> storeSave(String saveName, String json);
}


class MobileSaveStorage implements SaveStorage {
  @override
  Future<String?> loadSaveJson(String saveName) {
    // TODO: implement loadSaveJson
    throw UnimplementedError();
  }

  @override
  Future<List<String>> listSaveNames() {
    // TODO: implement loadSaveNames
    throw UnimplementedError();
  }

  @override
  Future<bool> storeSave(String saveName, String json) {
    // TODO: implement saveSave
    throw UnimplementedError();
  }

}

class WebSaveStorage implements SaveStorage {
  static const _saveNamesKey = '_saveNames';
  static const _saveKeyPrefix = '_save_entry';

  @override
  Future<List<String>> listSaveNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_saveNamesKey) ?? [];
  }

  @override
  Future<String?> loadSaveJson(String saveName) async {
    final prefs = await SharedPreferences.getInstance();
    String saveKey = _saveKey(saveName);
    if (!prefs.containsKey(saveKey)) {
      return null;
    }
    return prefs.getString(saveKey);
  }

  @override
  Future<bool> storeSave(String saveName, String json) async {
    final prefs = await SharedPreferences.getInstance();
    String saveKey = _saveKey(saveName);
    bool didSave = await prefs.setString(saveKey, json);
    if (didSave) {
      final saveNames = await listSaveNames();
      if (!saveNames.contains(saveName)) {
        saveNames.add(saveName);
        await prefs.setStringList(_saveNamesKey, saveNames);
      }
      return true;
    }
    return false;
  }

  String _saveKey(String saveName) => "${_saveKeyPrefix}_$saveName";

}

abstract class SaveService {

  Future<List<String>> listSaveNames();

  Future<Teamlytic> loadSave(String saveName);

  Future<void> storeSave(Teamlytic save);
}

class DummySaveService implements SaveService {
  @override
  Future<List<String>> listSaveNames() async {
    return [];
  }

  @override
  Future<Teamlytic> loadSave(String saveName) async {
    return Teamlytic(saveName: saveName, sdNames: [], replays: [], pokepaste: null);
  }

  @override
  Future<void> storeSave(Teamlytic save) async {
  }
}

class SaveServiceImpl implements SaveService {

  final SaveStorage _storage;
  final SdReplayParser _replayParser;

  SaveServiceImpl({required SaveStorage storage, required final SdReplayParser replayParser}) : _storage = storage, _replayParser = replayParser;

  @override
  Future<List<String>> listSaveNames() async => await _storage.listSaveNames();

  @override
  Future<Teamlytic> loadSave(String saveName) async {
    String? json = await _storage.loadSaveJson(saveName);
    if (json == null) {
      return _emptySave(saveName);
    }
    Map<dynamic, dynamic> map = jsonDecode(json);
    return Teamlytic(saveName: saveName, sdNames: _loadSdNames(map['sdNames']), replays: await _loadReplays(map['replays']), pokepaste: _loadPokepaste(map['pokepaste']));
  }

  @override
  Future<void> storeSave(Teamlytic save) async => _storage.storeSave(save.saveName, jsonEncode(save.toJson()));

  List<String> _loadSdNames(List<dynamic> rawSdNames) => rawSdNames.map((sdName) => sdName.toString()).toList();
  Pokepaste? _loadPokepaste(Map<String, dynamic>? json) => json != null ? Pokepaste.fromJson(json) : null;

  Future<List<Replay>> _loadReplays(List<dynamic> jsonReplays) async {
    List<Replay> replays = [];
    for (Map<String, dynamic> replayJson in jsonReplays) {
      final String? version = replayJson['data']['parserVersion'];
      if (version != SdReplayParser.perserVersion) {
        Uri uri = Uri.parse(replayJson['uri'] as String);
        developer.log("Replay $uri has different version ($version) than the app's current replay version (${SdReplayParser.perserVersion}). Reloading it...");
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          developer.log("Error: Failed to reload replay $uri. Got status code ${response.statusCode}");
          // maybe I should handle this better. e.g. allow having a replay without data and add a reload button in the UI
          continue;
        }
        final data = jsonDecode(response.body);
        SdReplayData fetchedReplayData = _replayParser.parse(data);
        String opposingPlayerName = replayJson['opposingPlayer']['name'];
        String? gameOutputStr = replayJson['gameOutput'];
        GameOutput output = GameOutput.values.firstWhere(
              (e) => e.name == gameOutputStr,
          orElse: () => GameOutput.UNKNOWN,
        );
        PlayerData opposingPlayer = fetchedReplayData.getPlayer(opposingPlayerName) ?? fetchedReplayData.player1;
        replays.add(Replay(uri: uri, data: fetchedReplayData, opposingPlayer: opposingPlayer, gameOutput: output));
      } else {
        replays.add(Replay.fromJson(replayJson));
      }
    }
    return replays;
  }

  Teamlytic _emptySave(String saveName) => Teamlytic(saveName: saveName, sdNames: [], replays: [], pokepaste: null);

}