import 'package:flutter/material.dart';

import '../../../../data/models/replay.dart';
import '../teamlytics_viewmodel.dart';

class GameByGameViewModel extends TeamlyticsTabViewModel {

  final Map<Replay, NoteEditingContext> _replayNoteEditingContextMap = {};

  GameByGameViewModel({required super.homeViewModel});

  NoteEditingContext getEditingContext(Replay replay) => _replayNoteEditingContextMap.putIfAbsent(replay, () => NoteEditingContext());

  void saveNotes(Replay replay, NoteEditingContext context) {
    replay.notes = context.controller?.text;
    homeViewModel.storeSave();
    context.view();
  }

  void dispose() {
    for (NoteEditingContext context in _replayNoteEditingContextMap.values) {
      context.dispose();
    }
  }
}

class NoteEditingContext extends ChangeNotifier {
  TextEditingController? _controller;
  TextEditingController? get controller => _controller;

  NoteEditingContext();

  void edit({String? initialValue}) {
    _controller = TextEditingController(text: initialValue);
    notifyListeners();
  }

  void view() {
    _controller = null;
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}