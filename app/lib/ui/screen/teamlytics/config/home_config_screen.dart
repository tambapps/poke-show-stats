import '../../../core/widgets.dart';
import '../../../core/widgets/pokepaste_widget.dart';
import 'home_config_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:pokepaste_parser/pokepaste_parser.dart';

import '../../../core/localization/applocalization.dart';
import '../../../core/themes/dimens.dart';


class HomeConfigComponent extends StatefulWidget {
  final HomeConfigViewModel viewModel;
  final bool isMobile;

  const HomeConfigComponent({super.key, required this.viewModel, required this.isMobile});


  @override
  _HomeConfigComponentState createState() => isMobile ? _MobileHomeConfigComponentState() : _DesktopHomeConfigComponentState();
}

abstract class _HomeConfigComponentState extends AbstractState<HomeConfigComponent> {

  late TextEditingController _pokepasteController;

  HomeConfigViewModel get viewModel => widget.viewModel;

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    final padding = EdgeInsets.symmetric(horizontal: dimens.defaultScreenMargin);
    return ListView(
      children: [
        SizedBox(height: dimens.homeConfigScreenTopPadding,),
        Padding(padding: padding, child: Text(viewModel.saveName, style: theme.textTheme.titleLarge?.copyWith(fontSize: 40.0),),),
        const SizedBox(height: 16.0,),
        Padding(padding: padding,
          child: Row(
          children: [
            Text(localization.showdownNames, style: theme.textTheme.titleLarge,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            OutlinedButton(
              onPressed: () => viewModel.addSdNameDialog(context, localization),
              child: Text(localization.add,),
            )
          ],
        ),),
        Padding(
          padding: padding,
          child: GridView.builder(
              shrinkWrap: true, // Makes the GridView wrap its content
              itemCount: viewModel.sdNames.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: dimens.sdNamesMaxCrossAxisExtent, // Maximum width of each grid item
                mainAxisSpacing: 10, // Spacing between rows
                crossAxisSpacing: 10, // Spacing between columns
                childAspectRatio: 4, // Aspect ratio of each grid item
              ),
              itemBuilder: (context, index) {
                final sdName = viewModel.sdNames[index];
                return Row(children: [
                  Container(constraints: BoxConstraints(maxWidth: dimens.sdNameMaxWidth), child: Tooltip(message: sdName, child: Text(sdName, overflow: TextOverflow.ellipsis,),),),
                  IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => viewModel.removeSdName(sdName))
                ],);
              }
          ),),
        const SizedBox(height: 32.0,),
        // pokepaste
        ...pokepaste(localization, dimens, theme, padding),
        const SizedBox(height: 32.0,),
        Padding(padding: EdgeInsets.only(left: 16.0),
          child: Align(alignment: Alignment.topLeft, child: OutlinedButton(onPressed: () => viewModel.exportSave(), child: Text("export team")),),),
        const SizedBox(height: 32.0,),
      ],
    );
  }

  List<Widget> pokepasteSection(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste);

  List<Widget> pokepaste(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding) {
    final pokepaste = viewModel.pokepaste;
    final title = Text(localization.pokepaste, style: theme.textTheme.titleLarge,);
    if (pokepaste == null) {
      return pokepasteForm(localization, theme, padding, title);
    } else {
      return pokepasteSection(localization, dimens, theme, padding, title, pokepaste);
    }
  }

  List<Widget> pokepasteForm(AppLocalization localization, ThemeData theme, EdgeInsets padding, Widget title) {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: padding, child: title,),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Padding(
            padding: padding,
            child: TextField(
              maxLines: null,
              controller: _pokepasteController,
              decoration: InputDecoration(
                labelText: localization.pasteSomething,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder(valueListenable: viewModel.pokepasteLoadingNotifier,
                  builder: (context, pokepasteLoading, _) => pokepasteLoading ? CircularProgressIndicator()  : OutlinedButton(
                    onPressed: () => viewModel.loadPokepaste(_pokepasteController),
                    child: Text(localization.load,),
                  )),
            ),
          )
        ],)
    ];
  }

  @override
  void initState() {
    _pokepasteController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pokepasteController.dispose();
    super.dispose();
  }
}

class _MobileHomeConfigComponentState extends _HomeConfigComponentState {

  @override
  List<Widget> pokepasteSection(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste) {
    return [
      Row(
        children: [
          title,
          SizedBox(width: 16,),
          OutlinedButton(
            onPressed: () => viewModel.removePokepaste(),
            child: Text(localization.change,),
          )
        ],
      ),
      Padding(
        padding: padding,
        child: PokepasteWidget(pokepaste: pokepaste, pokemonResourceService: viewModel.pokemonResourceService),
      ),
    ];

  }
}

class _DesktopHomeConfigComponentState extends _HomeConfigComponentState {

  @override
  List<Widget> pokepasteSection(AppLocalization localization, Dimens dimens, ThemeData theme, EdgeInsets padding, Widget title, Pokepaste pokepaste) {
    return [
      Padding(
        padding: padding,
        child: Row(
          children: [
            title,
            SizedBox(width: 16,),
            OutlinedButton(
              onPressed: () => viewModel.removePokepaste(),
              child: Text(localization.change,),
            )
          ],
        ),
      ),
      SizedBox(height: 16,),
      PokepasteWidget(pokepaste: pokepaste, pokemonResourceService: viewModel.pokemonResourceService)
    ];
  }

}