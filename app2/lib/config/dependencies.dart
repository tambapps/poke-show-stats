import 'package:flutter/services.dart';

import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'package:yaml/yaml.dart';

List<SingleChildWidget> get providers {
  return [
    FutureProvider(
      lazy: true,
      initialData: PokemonImageService(),
      create: (context) async => PokemonImageService(
        mappings: loadYaml(await rootBundle.loadString('assets/pokemon-sprite-urls.yaml'))
      ), // will load the yaml mapping
    ),
    Provider(
      lazy: true,
      create: (context) => SdReplayParser(),
    ),
    Provider(
      lazy: true,
      create: (context) => PokepasteParser(),
    )
  ];
}
