import 'package:file_picker/file_picker.dart';

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

class Sample {

  final String name;
  final String ruleset;

  Sample(this.name, this.ruleset);

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
          child: newTeamButtons(context, localization, dimens, theme),),),
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

  Widget newTeamButtons(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);

  void _importTeam() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(dialogTitle: "Import team", type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    final text = await file.xFile.readAsString();
    viewModel.importSave(text);
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
        // reload in case some modifications were made (e.g; a save deleted/created, team-sheet changed...)
        onTap: () => context.push(Routes.teamlyticsRoute(save.saveName)).then((_) => viewModel.loadSaves()),
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
      viewModel.createSave(name.trim());
      return true;
    });
  }


  void _sampleTeamDialog(BuildContext context, AppLocalization localization) async {
    final List<Sample> samples = [
      Sample('Electrizer', 'Reg G'),
      Sample('DelpHOx', 'Reg H'),
      Sample('Sunny day Happy day', 'Reg I')
    ];
    String? sampleName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a sample'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: samples.map((sample) {
                return ListTile(
                  title: Text("${sample.name} | ${sample.ruleset}"),
                  onTap: () => Navigator.pop(context, sample.name),
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
    await viewModel.createSaveFromSample(sampleName);
  }

  void _changeNameDialog(BuildContext context, AppLocalization localization, TeamlyticPreview save) {
    showTextInputDialog(context, title: "Change name", hint: "Enter team name", localization: localization,
        initialValue: save.saveName,
        confirmButtonText: "Update",
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
          }, child: Text("Delete", style: TextStyle(color: Colors.red)))
        ],
      );
    });
  }
}

class _MobileHomeState extends _AbstractHomeState {
  @override
  Widget newTeamButtons(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(children: [
      Row(children: [
        OutlinedButton(onPressed: () => _createTeamDialog(context, localization), child: Text("new team")),
        const SizedBox(width: 32.0,),
        OutlinedButton(onPressed: () => _sampleTeamDialog(context, localization), child: Text("sample team"))
      ],),
      const SizedBox(height: 16.0,),
      Row(children: [
        OutlinedButton(onPressed: () => _importTeam(), child: Text("import team")),
      ],)
    ],);
  }
}

class _DesktopHomeState extends _AbstractHomeState {

  @override
  Widget newTeamButtons(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Row(children: [
      OutlinedButton(onPressed: () => _createTeamDialog(context, localization), child: Text("new team")),
      const SizedBox(width: 32.0,),
      OutlinedButton(onPressed: () => _sampleTeamDialog(context, localization), child: Text("sample team")),
      const SizedBox(width: 32.0,),
      OutlinedButton(onPressed: () => _importTeam(), child: Text("import team"))
    ],);
  }
}