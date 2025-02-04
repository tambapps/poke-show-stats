
import 'package:flutter/material.dart';

import '../../../data/services/pokemon_resource_service.dart';

class AboutViewModel extends ChangeNotifier {
  final PokemonResourceService pokemonResourceService;

  AboutViewModel({required this.pokemonResourceService});

}