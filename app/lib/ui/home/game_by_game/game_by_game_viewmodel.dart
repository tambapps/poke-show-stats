import 'package:flutter/material.dart';

import '../../../data/models/replay.dart';
import '../home_viewmodel.dart';

class GameByGameViewModel extends ChangeNotifier {
  GameByGameViewModel({
    required this.homeViewModel});

  final HomeViewModel homeViewModel;
  List<Replay> get replays => homeViewModel.replays;

}
