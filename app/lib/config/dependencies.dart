import 'package:app2/data/services/save_service.dart';
import 'package:flutter/foundation.dart';

import 'package:app2/data/services/pokemon_resource_service.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

List<SingleChildWidget> get providers {
  return [
    ListenableProvider(
      create: (context) => PokemonResourceService(),
    ),
    Provider(
      create: (context) => SdReplayParser(),
    ),
    Provider(
      create: (context) => PokepasteParser(),
    ),
    Provider<SaveStorage>(
      create: (context) => kIsWeb ? WebSaveStorage() : MobileSaveStorage(),
    ),
    ProxyProvider2<SaveStorage, SdReplayParser, SaveService>(
      create: (context) => DummySaveService(),
      update: (context, saveStorage, replayParser,_) => SaveServiceImpl(storage: saveStorage, replayParser: replayParser),
    )
  ];
}
