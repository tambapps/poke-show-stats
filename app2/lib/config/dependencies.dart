


import 'package:app2/data/services/pokemon_image_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providers {
  return [
    FutureProvider(
      initialData: DummyPokemonImageService(),
      create: (context) async => PokemonImageServiceImpl(), // will load the yaml mapping
    ),
  ];
}
