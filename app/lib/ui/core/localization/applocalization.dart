// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Simple Localizations similar to
/// https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#an-alternative-class-for-the-apps-localized-resources
class AppLocalization {
  static AppLocalization of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  static const _strings = <String, String>{
    'home': 'Home',
    'replayEntries': 'Replay Entries',
    'gameByGame': 'Game by Game',
    'moveUsages': 'Move Usages',
    'sdNames': 'Showdown names',
    'addSdName': 'Add Pokemon Showdown name',
    'enterSdName': 'Enter name',
    'pokepaste': 'Pokepaste',
    'pasteSomething': 'Paste the pokepaste\'s content here (not the URL)',
    'load': 'Load',
    'change': 'Change',
    'add': 'Add',
    'ok': 'OK',
    'cancel': 'Cancel',
    'you': 'You',
    'opponent': 'Opponent',
    'editNotes': 'Edit notes',
    'addNotes': 'Add notes',
    'notes': 'Notes',
    'save': 'Save',
    'replay': 'Replay',
    'replayUrl': 'Replay URL',
    'replayUrls': 'Replay URL(s)',
    'opposingTeam': 'Opposing Team',
    'leadStats': 'Lead Stats',
    'usageStats': 'Usage Stats',
    'matchUpNotes': 'Match-up Notes',
  };

  // If string for "label" does not exist, will show "[LABEL]"
  static String _get(String label) =>
      _strings[label] ?? '[${label.toUpperCase()}]';

  String get home => _get('home');
  String get replayEntries => _get('replayEntries');
  String get gameByGame => _get('gameByGame');
  String get moveUsages => _get('moveUsages');
  String get leadStats => _get('leadStats');
  String get usageStats => _get('usageStats');
  String get matchUpNotes => _get('matchUpNotes');
  String get showdownNames => _get('sdNames');
  String get addSdName => _get('addSdName');
  String get enterSdName => _get('enterSdName');
  String get pokepaste => _get('pokepaste');
  String get pasteSomething => _get('pasteSomething');
  String get load => _get('load');
  String get change => _get('change');
  String get add => _get('add');
  String get cancel => _get('cancel');
  String get ok => _get('ok');
  String get you => _get('you');
  String get opponent => _get('opponent');
  String get editNotes => _get('editNotes');
  String get addNotes => _get('addNotes');
  String get notes => _get('notes');
  String get save => _get('save');
  String get replay => _get('replay');
  String get replayUrl => _get('replayUrl');
  String get replayUrls => _get('replayUrls');
  String get opposingTeam => _get('opposingTeam');

  String selected(int value) =>
      _get('selected').replaceAll('{1}', value.toString());
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture(AppLocalization());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) =>
      false;
}
