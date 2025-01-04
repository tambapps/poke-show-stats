import 'package:app/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class StorageService {
  static const String _replaysKey = 'replays';

  Future<void> saveReplays(List<Replay> replays) async {
    await _save(replays, (replay) => replay.toJson(), _replaysKey);
  }

  Future<List<Replay>> loadReplays() async {
    return await _load((json) => Replay.fromJson(json), _replaysKey);
  }

  Future<void> clearReplays() async {
    await clear(_replaysKey);
  }

  Future<List<T>> _load<T>(T Function(Map<String, dynamic>) fromJson, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(key);

    if (jsonList == null) {
      return [];
    }

    // Deserialize JSON strings to Replay objects
    return jsonList.map((jsonStr) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return fromJson(jsonMap);
    }).toList();
  }

  Future<void> _save<T>(List<T> objects, Map<String, dynamic> Function(T) toJson, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Serialize list of Replay objects to JSON
    List<String> jsonList = objects.map((object) => jsonEncode(toJson(object))).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<void> clear(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
