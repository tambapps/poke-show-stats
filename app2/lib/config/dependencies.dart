


import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

List<SingleChildWidget> get providers {
  return [
    FutureProvider(
      lazy: true,
      initialData: DummyPokemonImageService(),
      create: (context) async => PokemonImageServiceImpl(), // will load the yaml mapping
    ),
    Provider(
      lazy: true,
      create: (context) => SdReplayParser(),
    )
  ];
}
