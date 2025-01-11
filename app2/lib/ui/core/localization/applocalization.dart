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
    'usageStats': 'Usage Stats',
    'sdNames': 'Showdown names',
    'addSdName': 'Add name',
    'pokepaste': 'Pokepaste',
    'pasteSomething': 'Paste something here!',
    'load': 'Load',
  };

  // If string for "label" does not exist, will show "[LABEL]"
  static String _get(String label) =>
      _strings[label] ?? '[${label.toUpperCase()}]';

  String get home => _get('home');
  String get replayEntries => _get('replayEntries');
  String get usageStats => _get('usageStats');
  String get showdownNames => _get('sdNames');
  String get addSdName => _get('addSdName');
  String get pokepaste => _get('pokepaste');
  String get pasteSomething => _get('pasteSomething');
  String get load => _get('load');

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
