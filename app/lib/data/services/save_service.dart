import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import '../models/replay.dart';
import '../models/teamlytic.dart';
import 'package:path_provider/path_provider.dart';
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
  static const _saveNamesKey = '_saveNames';

  // uses SharedPreferences for save names, file for the resst

  @override
  Future<String?> loadSaveJson(String saveName) async {
    try {
      final directory = await _getSavesDirectory();
      final file = File('${directory.path}/$saveName.json');
      if (!await file.exists()) {
        return null; // Return null if the file doesn't exist
      }
      return await file.readAsString();
    } catch (e) {
      developer.log('Error loading save $saveName', error: e);
      return null;
    }
  }

  @override
  Future<bool> storeSave(String saveName, String json) async {
    try {
      // Get the app's documents directory
      final directory = await _getSavesDirectory();
      final file = File('${directory.path}/$saveName.json');
      await file.writeAsString(json, flush: true);
      return true;
    } catch (e) {
      developer.log('Error storing save $saveName', error: e);
      return false;
    }
  }

  @override
  Future<List<String>> listSaveNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_saveNamesKey) ?? [];
  }

  Future<Directory> _getSavesDirectory() async {
    final rootDir = await getApplicationDocumentsDirectory();
    final saveDirPath = '${rootDir.path}/saves';
    final savesDirectory = Directory(saveDirPath);
    if (!await savesDirectory.exists()) {
      await savesDirectory.create(recursive: true);
    }
    return savesDirectory;
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

  Future<List<TeamlyticPreview>> listSaves();

  Future<Teamlytic> loadSave(String saveName);

  Future<void> storeSave(Teamlytic save);
}

class DummySaveService implements SaveService {
  @override
  Future<List<TeamlyticPreview>> listSaves() async {
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
  Future<List<TeamlyticPreview>> listSaves() async {
    var saveNames = await _storage.listSaveNames() + List.generate(10, (i) => "default");
    List<TeamlyticPreview> saves = [];
    for (String saveName in saveNames) {
      String? json = await _storage.loadSaveJson(saveName);
      Pokepaste? pokepaste;
      if (json != null) {
        Map<dynamic, dynamic> map = jsonDecode(json);
        pokepaste = _loadPokepaste(map['pokepaste']);
      }
      saves.add(TeamlyticPreview(saveName: saveName, pokepaste: pokepaste));
    }
    return saves;
  }

  @override
  Future<Teamlytic> loadSave(String saveName) async {
    String? json = await _storage.loadSaveJson(saveName);
    if (json == null) {
      return _emptySave(saveName);
    }
    Map<dynamic, dynamic> map = jsonDecode(json);
    List<bool> reloadedReplayRef = [false];
    final teamlytic = Teamlytic(
        saveName: saveName,
        sdNames: _loadSdNames(map['sdNames']),
        replays: await _loadReplays(map['replays'], reloadedReplayRef),
        pokepaste: _loadPokepaste(map['pokepaste'])
    );
    if (reloadedReplayRef[0]) {
      storeSave(teamlytic);
    }
    return teamlytic;
  }

  @override
  Future<void> storeSave(Teamlytic save) async => _storage.storeSave(save.saveName, jsonEncode(save.toJson()));

  List<String> _loadSdNames(List<dynamic> rawSdNames) => rawSdNames.map((sdName) => sdName.toString()).toList();
  Pokepaste? _loadPokepaste(Map<String, dynamic>? json) => json != null ? Pokepaste.fromJson(json) : null;

  Future<List<Replay>> _loadReplays(List<dynamic> jsonReplays, List<bool> reloadedReplayRef) async {
    List<Replay> replays = [];
    for (Map<String, dynamic> replayJson in jsonReplays) {
      final String? version = replayJson['data']['parserVersion'];
      if (version != SdReplayParser.parserVersion) {
        reloadedReplayRef[0] = true;
        Uri uri = Uri.parse(replayJson['uri'] as String);
        developer.log("Replay $uri has different version ($version) than the app's current replay version (${SdReplayParser.parserVersion}). Reloading it...");
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          developer.log("Error: Failed to reload replay $uri. Got status code ${response.statusCode}");
          // maybe I should handle this better. e.g. allow having a replay without data and add a reload button in the UI
          replays.add(_errorReplay(uri));
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
    // reversed because in case of 3 games, G2 must have its elo in order for G1 to find it
    for (Replay replay in replays.reversed) {
      if (replay.data.player1.beforeElo == null && replay.data.player1.afterElo == null
          && replay.data.nextBattle != null) {
        // we're in an intermediate battle (G1 or G2 when it is not the last game) and we need to fetch elo from final battle
        replay.trySetElo(replays);
      }
    }
    return replays;
  }

  Teamlytic _emptySave(String saveName) => Teamlytic(saveName: saveName, sdNames: [], replays: [], pokepaste: null);

  Replay _errorReplay(Uri uri) {
    final player = _errorPlayer();
    final data = SdReplayData(player1: player, player2: player, uploadTime: DateTime.now().millisecondsSinceEpoch, formatId: 'error', rating: 0, parserVersion: SdReplayParser.parserVersion, winner: player.name, nextBattle: null);
    return Replay(uri: uri, data: data, gameOutput: GameOutput.UNKNOWN, opposingPlayer: _errorPlayer());
  }

  PlayerData _errorPlayer() => PlayerData(name: "<ERROR>", team: [], selection: [], moveUsages: {});
}

