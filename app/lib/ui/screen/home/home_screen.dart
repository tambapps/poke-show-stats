import '../../core/dialogs.dart';

import '../../../data/models/teamlytic.dart';
import '../../../data/services/pokemon_resource_service.dart';
import '../../../routing/routes.dart';
import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';
import '../../core/widgets.dart';
import '../../core/widgets/auto_gridview.dart';
import 'home_viewmodel.dart';
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

abstract class _AbstractHomeState extends AbstractScreenState<HomeScreen> {

  HomeViewModel get viewModel => widget.viewModel;
  @override
  PokemonResourceService get pokemonResourceService => viewModel.pokemonResourceService;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Scaffold(
        body: body(context, localization, dimens, theme));
  }

  Widget body(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16.0,),
        Align(alignment: Alignment.center, child: Text("Poke ShowStats", style: theme.textTheme.titleLarge,),),
        Align(alignment: Alignment.center, child: Text("Welcome to Poke ShowStats, an app to get valuable insights from your Pokemon Showdown replays", style: theme.textTheme.labelLarge, textAlign: TextAlign.center,),),
        Padding(padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 16.0), child: Align(alignment: Alignment.topLeft,
          child: Text("Teams", style: theme.textTheme.titleMedium,),),),
        Padding(padding: EdgeInsets.only(left: 16.0, bottom: 16.0), child: Align(alignment: Alignment.topLeft,
          child: Row(children: [
            OutlinedButton(onPressed: () => _createTeamDialog(context, localization), child: Text("new team")),
            const SizedBox(width: 32.0,),
            OutlinedButton(onPressed: () => _sampleTeamDialog(context, localization), child: Text("sample team"))
          ],),),),
        Expanded(child: ValueListenableBuilder(
          valueListenable: viewModel.loading,
          builder: (context, loading, child) {
            if (loading) {
              return CircularProgressIndicator();
            }
            return ValueListenableBuilder(valueListenable: viewModel.saves,
                builder: (context, saves, _) => SingleChildScrollView(child:
                AutoGridView(columnsCount: dimens.savesColumnCount,
                    children: saves.map((save) => _saveWidget(save, context, localization, dimens, theme)).toList()),));
          },
        )),
        Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), child: _aboutButton(),),)
      ],);
  }

  Widget _aboutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12), // Rounded edges
      onTap: () => context.push(Routes.about),
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), child:  Text("About"),),
    );
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
                Align(alignment: Alignment.topRight, child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.edit), iconSize: 16, onPressed: () => _changeNameDialog(context, localization, save)),
                    IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => _deleteSaveDialog(context, localization, save))
                ],),)
              ],),
              if (pokepaste != null)
                Row(mainAxisSize: MainAxisSize.max,
                  children: pokepaste.pokemons.map((pokemon) => Expanded(child: viewModel.pokemonResourceService.getPokemonSprite(pokemon.name))).toList(),),
              const SizedBox(height: 16.0,)
            ],),
        ),
      ),
    );
  }

  void _createTeamDialog(BuildContext context, AppLocalization localization) {
    showTextInputDialog(context, title: "New team", hint: "Enter team name", localization: localization,
        validator: (input) {
          String name = input.trim();
          if (name.isEmpty) {
            return "Name must not be empty";
          }
          if (viewModel.saves.value.any((s) => s.saveName == name)) {
            return "Team already exists";
          }
          return null;
        },
        onSuccess: (name) {
      viewModel.createSave(name.trim()).then((teamlytic) => context.push(Routes.teamlyticsRoute(teamlytic.saveName)));
      return true;
    });
  }

  void _sampleTeamDialog(BuildContext context, AppLocalization localization) async {
    final List<String> items = ['electrizer'];
    String? sampleName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a sample'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return ListTile(
                  title: Text(item),
                  onTap: () => Navigator.pop(context, item),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (sampleName == null) {
      return;
    }
    final teamlytic = await viewModel.createSaveFromSample(sampleName);
    context.push(Routes.teamlyticsRoute(teamlytic.saveName));
  }

  void _changeNameDialog(BuildContext context, AppLocalization localization, TeamlyticPreview save) {
    showTextInputDialog(context, title: "Change name", hint: "Enter team name", localization: localization,
        validator: (input) {
          String name = input.trim();
          if (name.isEmpty) {
            return "Name must not be empty";
          }
          if (viewModel.saves.value.any((s) => s.saveName == name && name != save.saveName)) {
            return "Team already exists";
          }
          return null;
        },
        onSuccess: (name) {
          viewModel.changeName(name.trim(), save);
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