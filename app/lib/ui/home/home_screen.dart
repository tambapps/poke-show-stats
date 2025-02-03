import 'package:app2/ui/core/dialogs.dart';

import '../../data/models/teamlytic.dart';
import '../../routing/routes.dart';
import '../core/localization/applocalization.dart';
import '../core/themes/dimens.dart';
import '../core/widgets.dart';
import '../core/widgets/auto_gridview.dart';
import './home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  final HomeViewModel viewModel;
  final bool isMobile;

  @override
  State<StatefulWidget> createState() => isMobile ? _MobileHomeState() : _DesktopHomeState();
}

abstract class _AbstractHomeState extends AbstractViewModelState<HomeScreen> {

  @override
  HomeViewModel get viewModel => widget.viewModel;


  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Padding(padding: EdgeInsets.only(top: dimens.screenBoundsTopMargin), child: Scaffold(
        body: ListenableBuilder(listenable: viewModel, builder: (context, _) => body(context, localization, dimens, theme))));
  }

  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return SingleChildScrollView(child:
    Column(
      children: [
        const SizedBox(height: 16.0,),
        Align(alignment: Alignment.center, child: Text("Poke ShowStats", style: theme.textTheme.titleLarge,),),
        Align(alignment: Alignment.center, child: Text("Welcome to Poke ShowStats, an app to get valuable insights from your Pokemon Showdown replays", style: theme.textTheme.labelLarge, textAlign: TextAlign.center,),),
        Padding(padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 16.0), child: Align(alignment: Alignment.topLeft,
          child: Text("Teams", style: theme.textTheme.titleMedium,),),),

        Padding(padding: EdgeInsets.only(left: 16.0, bottom: 16.0), child: Align(alignment: Alignment.topLeft,
          child: OutlinedButton(onPressed: () => _createTeamDialog(context, localization), child: Text("add team")),),),
        !viewModel.loading ? AutoGridView(columnsCount: dimens.savesColumnCount, children: viewModel.saves.map((save) => _saveWidget(save, context, localization, dimens, theme)).toList())
        : CircularProgressIndicator(),
        // hack for android in order not to overlap the android system navigation bar
        if (dimens.isMobile) SizedBox(height: MediaQuery.of(context).viewPadding.bottom,)
      ],),);
  }

  Widget _saveWidget(TeamlyticPreview save, BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final pokepaste = save.pokepaste;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: InkWell(
        onTap: () => context.push(Routes.teamlyticsRoute(save.saveName)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey,
                width: 2.0
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(children: [
                Center(child: Text(save.saveName, style: theme.textTheme.titleMedium,),),
                Align(alignment: Alignment.topRight, child: IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => _deleteSaveDialog(context, localization, save)),)
              ],),
              if (pokepaste != null)
                Row(mainAxisSize: MainAxisSize.max,
                  // TODO bug, images not loaded on first page load
                  children: pokepaste.pokemons.map((pokemon) => Expanded(child: viewModel.pokemonResourceService.getPokemonSprite(pokemon.name))).toList(),),
              const SizedBox(height: 16.0,)
            ],),
        ),
      ),
    );
  }

  void _createTeamDialog(BuildContext context, AppLocalization localization) {
    showTextInputDialog(context, title: "New team", hint: "Enter team name", localization: localization,
        validator: (input) => input.trim().isNotEmpty ? null : "Name must not be empty",
        onSuccess: (name) {
          context.push(Routes.teamlyticsRoute(name.trim()));
          return true;
        });
  }

  void _deleteSaveDialog(BuildContext context, AppLocalization localization, TeamlyticPreview save) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Delete team ${save.saveName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(localization.cancel,)),
          TextButton(onPressed: () {
            viewModel.deleteSave(save);
            Navigator.of(context).pop();
          }, child: Text("yes", style: TextStyle(color: Colors.red)))
        ],
      );
    });
  }
}

class _MobileHomeState extends _AbstractHomeState {

}

class _DesktopHomeState extends _AbstractHomeState {

}