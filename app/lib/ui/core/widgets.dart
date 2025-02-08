import 'package:flutter/material.dart';
import 'localization/applocalization.dart';
import 'themes/dimens.dart';

import '../../../data/services/pokemon_resource_service.dart';

abstract class AbstractState<T extends StatefulWidget> extends State<T> {

  @override
  Widget build(BuildContext context) {
    return doBuild(context, AppLocalization.of(context), Dimens.of(context), Theme.of(context));
  }

  @protected
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
}

// TODO delete this
abstract class AbstractViewModelState<T extends StatefulWidget> extends AbstractState<T> {

  ChangeNotifier get viewModel;

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}



abstract class AbstractStatelessWidget extends StatelessWidget {

  const AbstractStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return doBuild(context, AppLocalization.of(context), Dimens.of(context), Theme.of(context));
  }

  @protected
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);


}

abstract class AbstractScreenState<T extends StatefulWidget> extends AbstractState<T>  {

  PokemonResourceService get pokemonResourceService;

  @override
  Widget build(BuildContext context) {
    // for android in order not to overlap the android system navigation bar and status bar
    return Padding(
        padding: MediaQuery.of(context).padding,
        child: ListenableBuilder(
          // need to listen to this because it loads assets asynchronously
            listenable: pokemonResourceService,
            builder: (context, _) => doBuild(context, AppLocalization.of(context), Dimens.of(context), Theme.of(context))
        )
    );
  }
}