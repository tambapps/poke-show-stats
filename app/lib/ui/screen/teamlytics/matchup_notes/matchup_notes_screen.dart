import 'package:flutter/material.dart';
import 'package:poke_showstats/data/models/matchup.dart';
import 'package:poke_showstats/ui/core/dialogs.dart';
import 'package:poke_showstats/ui/core/localization/applocalization.dart';
import 'package:poke_showstats/ui/core/themes/dimens.dart';
import 'package:poke_showstats/ui/screen/teamlytics/matchup_notes/matchup_notes_viewmodel.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../core/widgets.dart';

class MatchUpNotesComponent extends StatefulWidget {
  final MatchUpNotesViewmodel viewModel;
  final bool isMobile;
  final List<MatchUp> matchUps;

  const MatchUpNotesComponent({super.key, required this.viewModel, required this.isMobile, required this.matchUps, });

  @override
  State createState() => isMobile ? _MobileMatchUpNotesState() : _DesktopMatchUpNotesState();

}

abstract class _AbstractMatchUpNotesState extends AbstractState<MatchUpNotesComponent> {

  MatchUpNotesViewmodel get viewModel => widget.viewModel;
  List<MatchUp> get matchUps => widget.matchUps;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    if (matchUps.isEmpty) {
      return Center(child: Column(children: [
        const Padding(padding: EdgeInsets.only(top: 64.0)),
        Text("In this tab, you can define match-ups and add notes on how to handle them", style: theme.textTheme.bodyLarge,),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        createMatchUpButton(context, localization)
      ],),);
    }
    return Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: ListView.separated(itemBuilder: (context, index) {
        if (index >= matchUps.length) {
          return Padding(padding: EdgeInsets.only(top: 16.0), child: Center(
            child: createMatchUpButton(context, localization),
          ),);
        }
        final MatchUp matchUp = matchUps[index];
        final MatchUpEditingContext editingContext = viewModel.getContext(matchUp);
        return ListenableBuilder(listenable: editingContext, builder: (context, _) {
          if (editingContext.isEditing) {
            return editingMatchUpWidget(context, localization, dimens, theme, matchUp, editingContext);
          } else {
            return matchUpWidget(context, localization, dimens, theme, matchUp);
          }
        });
      }, separatorBuilder: (context, index) {
        if (index >= matchUps.length - 1) {
          return Container();
        }
        return Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0), child: Divider(
          color: Colors.grey,
          thickness: 2,
          height: 1,
        ),);
      }, itemCount: matchUps.length + 1),);

  }

  Widget matchUpWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, MatchUp matchUp);
  Widget editingMatchUpWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, MatchUp matchUp, MatchUpEditingContext editingContext);

  Widget createMatchUpButton(BuildContext context, AppLocalization localization) => OutlinedButton(onPressed: () => _createMatchUp(context, localization), child: Text("new match-up"));
  void _createMatchUp(BuildContext context, AppLocalization localization) {
    showTextInputDialog(context,
        title: "New match-up",
        hint: "Match-up name",
        validator: (text) => text.trim().isEmpty ? "Name must not be empty" : null,
        localization: localization,
        onSuccess: (matchUpName) {
          viewModel.createMatchUp(matchUpName);
          return true;
        });
  }

  Widget teamSheetButton(BuildContext context, MatchUp matchUp) => IconButton(onPressed: () => showTeamSheetDialog(
    title: matchUp.name ?? "",
    pokepaste: matchUp.pokepaste!,
    context: context,
    pokemonResourceService: viewModel.pokemonResourceService
  ), icon: Icon(Icons.remove_red_eye));

  Widget editMatchUpButton(MatchUp matchUp) {
    return IconButton(icon: Icon(Icons.edit), iconSize: 20.0, onPressed: () => viewModel.getContext(matchUp).edit(matchUp: matchUp));
  }

  Widget editActionButtons(BuildContext context, MatchUpEditingContext editingContext, MatchUp matchUp) {
    return Align(alignment: Alignment.topRight, child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: () => viewModel.updateMatchUp(matchUp, editingContext.nameController.text, editingContext.notesController.text),
            iconSize: 32.0, icon: Icon(Icons.check), color: Colors.green),
        IconButton(onPressed: () => viewModel.deleteMatchUp(matchUp), iconSize: 32.0, icon: Icon(Icons.delete), color: Colors.red,)
      ],),);
  }
  Widget pokepasteButton(MatchUp matchUp, AppLocalization localization) {
    return OutlinedButton(onPressed: () {
      showTextInputDialog(context,
          title: localization.pokepaste,
          hint: localization.pasteSomething,
          initialValue: matchUp.pokepaste?.toString(),
          maxLines: null,
          validator: (text) => viewModel.validatePokepaste(text),
          localization: localization,
          onSuccess: (text) {
            Pokepaste? pokepaste = viewModel.parsePokepaste(text);
            if (pokepaste == null) {
              return false;
            }
            viewModel.updatePokepaste(matchUp, pokepaste);
            return true;
          });
    }, child: Text(matchUp.pokepaste != null ? "change pokepaste" : "add pokepaste"));
  }
}

class _MobileMatchUpNotesState extends _AbstractMatchUpNotesState {
  @override
  Widget matchUpWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, MatchUp matchUp) {
    // TODO: implement matchUp
    throw UnimplementedError();
  }

  @override
  Widget editingMatchUpWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, MatchUp matchUp, MatchUpEditingContext editingContext) {
    // TODO: implement editingMatchUpWidget
    throw UnimplementedError();
  }

}

class _DesktopMatchUpNotesState extends _AbstractMatchUpNotesState {

  @override
  Widget matchUpWidget(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme, MatchUp matchUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Row(children: [
        Text(matchUp.name ?? "<no name>", style: theme.textTheme.titleLarge?.copyWith(fontSize: 32.0),),
        if (matchUp.pokepaste != null)
          ...[
            ...matchUp.pokepaste!.pokemons
                .map((pokemon) =>
                viewModel.pokemonResourceService.getPokemonSprite(pokemon.name)),
            const SizedBox(width: 16.0,),
            teamSheetButton(context, matchUp)
          ],
        Expanded(child: Container()),
        editMatchUpButton(matchUp)
      ],),

        const SizedBox(height: 16.0,),
        Text(matchUp.notes ?? "<no notes>")
    ],);
  }

  @override
  Widget editingMatchUpWidget(BuildContext context, AppLocalization localization,
      Dimens dimens, ThemeData theme, MatchUp matchUp, MatchUpEditingContext editingContext) {
    // theme.textTheme.titleLarge?.copyWith(fontSize: 32.0)
    const elementsPadding = SizedBox(height: 32.0,);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: editingContext.nameController,
          decoration: InputDecoration(
            labelText: "Match-up name",
            border: OutlineInputBorder(),
          ),
        ),
        elementsPadding,
        Row(children: [
          pokepasteButton(matchUp, localization),
          if (matchUp.pokepaste != null)
            ...matchUp.pokepaste!.pokemons
                .map((pokemon) =>
                viewModel.pokemonResourceService.getPokemonSprite(pokemon.name)),
        ],),
        elementsPadding,
        TextField(
          maxLines: null,
          controller: editingContext.notesController,
          decoration: InputDecoration(
            labelText: "Notes",
            border: OutlineInputBorder(),
          ),
        ),
        elementsPadding,
        editActionButtons(context, editingContext, matchUp),
      ],);
  }
}

