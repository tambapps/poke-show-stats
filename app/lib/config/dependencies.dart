import 'package:poke_showstats/ui/screen/home/home_viewmodel.dart';

import '../../../data/services/save_service.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/pokemon_resource_service.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../ui/screen/teamlytics/config/home_config_viewmodel.dart';
import '../ui/screen/teamlytics/teamlytics_viewmodel.dart';

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
    ),
    // view models
    ProxyProvider2<PokemonResourceService, SaveService, HomeViewModel>(
      update: (context, pokemonResourceService, saveService,_) => HomeViewModel(pokemonResourceService: pokemonResourceService, saveService: saveService),
    ),
    ProxyProvider2<PokemonResourceService, SaveService, TeamlyticsViewModel>(
      update: (context, pokemonResourceService, saveService,_) => TeamlyticsViewModel(pokemonResourceService: context.read(), saveService: context.read()),
    ),
  ];
}

List<SingleChildWidget> teamlyticsProviders(String saveName) {
  return [
    Provider(
      create: (context) => HomeConfigViewModel(homeViewModel: context.read(), pokepasteParser: context.read()),
    )
  ];
}