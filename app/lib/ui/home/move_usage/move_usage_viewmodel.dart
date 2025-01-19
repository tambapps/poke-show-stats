

import 'package:app2/data/models/replay.dart';
import 'package:app2/ui/core/widgets/replay_filters.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../home_viewmodel.dart';

class MoveUsageViewModel extends ChangeNotifier {

  MoveUsageViewModel({
    required this.homeViewModel,
  });

  final HomeViewModel homeViewModel;
  List<Replay> get filteredReplays => homeViewModel.replays;
  Pokepaste? get pokepaste => homeViewModel.pokepaste;

  void applyFilters(ReplayPredicate? replayPredicate) {
    // TODO
  }
}