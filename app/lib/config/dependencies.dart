import 'package:poke_showstats/data/models/teamlytic.dart';
import 'package:poke_showstats/ui/screen/home/home_viewmodel.dart';
import 'package:poke_showstats/ui/screen/teamlytics/game_by_game/game_by_game_viewmodel.dart';
import 'package:poke_showstats/ui/screen/teamlytics/match_by_match/match_by_match_viewmodel.dart';
import 'package:poke_showstats/ui/screen/teamlytics/matchup_notes/matchup_notes_viewmodel.dart';
import 'package:poke_showstats/ui/screen/teamlytics/replay_entries/replay_entries_viewmodel.dart';

import '../../../data/services/save_service.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/pokemon_resource_service.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';

import '../ui/screen/teamlytics/config/home_config_viewmodel.dart';
import '../ui/screen/teamlytics/lead_stats/lead_stats_viewmodel.dart';
import '../ui/screen/teamlytics/move_usage/move_usage_viewmodel.dart';
import '../ui/screen/teamlytics/teamlytics_viewmodel.dart';
import '../ui/screen/teamlytics/usage_stats/usage_stats_viewmodel.dart';

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
  ];
}

List<SingleChildWidget> teamlyticsProviders(Teamlytic teamlytic) {
  return [
    ProxyProvider2<PokemonResourceService, SaveService, TeamlyticsViewModel>(
      update: (context, pokemonResourceService, saveService,_) => TeamlyticsViewModel(
          teamlytic: teamlytic,
          pokemonResourceService: context.read(),
          saveService: context.read()),
      dispose: (_, viewModel) => viewModel.dispose(),
    ),
    ProxyProvider<TeamlyticsViewModel, HomeConfigViewModel> (
      update: (context, teamlyticsViewModel, _) => HomeConfigViewModel(teamlyticsViewmodel: teamlyticsViewModel, pokepasteParser: context.read(), saveService: context.read()), dispose: (c, v) => v.dispose(),
    ),
    ProxyProvider<TeamlyticsViewModel, ReplayEntriesViewModel> (
      update: (context, teamlyticsViewModel, _) => ReplayEntriesViewModel(teamlyticsViewModel: teamlyticsViewModel, replayParser: context.read()),
      dispose: (_, viewModel) => viewModel.dispose(),
    ),
    ProxyProvider<TeamlyticsViewModel, GameByGameViewModel> (
      update: (context, teamlyticsViewModel, _) => GameByGameViewModel(teamlyticsViewModel: teamlyticsViewModel),
      dispose: (_, viewModel) => viewModel.dispose(),
    ),
    ProxyProvider<TeamlyticsViewModel, MatchByMatchViewModel> (
      update: (context, teamlyticsViewModel, _) => MatchByMatchViewModel(),
    ),
    Provider(
      create: (context) => MoveUsageViewModel(),
    ),
    Provider (
      create: (context) => LeadStatsViewModel(pokemonResourceService: context.read()),
    ),
    Provider(
      create: (context) => UsageStatsViewModel(pokemonResourceService: context.read()),
    ),
    ProxyProvider<TeamlyticsViewModel, MatchUpNotesViewmodel> (
      update: (context, teamlyticsViewModel, _) => MatchUpNotesViewmodel(pokemonResourceService: context.read(), teamlyticsViewModel: teamlyticsViewModel, pokepasteParser: context.read()),
      dispose: (context, viewModel) => viewModel.dispose(),
    ),
  ];
}