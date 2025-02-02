import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../../../data/models/replay.dart';
import '../../../data/services/pokemon_resource_service.dart';
import '../../core/widgets/replay_filters.dart';
import '../home_viewmodel.dart';

class UsageStatsViewModel extends ChangeNotifier {
  final HomeViewModel homeViewModel;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;
  int get replaysCount => homeViewModel.filteredReplays.length;
//  bool get hasReplays => homeViewModel.replays.isNotEmpty;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final ReplayFiltersViewModel filtersViewModel;
  final PokemonResourceService pokemonResourceService;

  UsageStatsViewModel({required this.homeViewModel,
    required this.pokemonResourceService,
    required this.filtersViewModel,
  }) {
  //  loadUsages();
  }



}
