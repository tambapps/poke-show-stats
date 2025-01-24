import 'package:flutter/material.dart';
import 'localization/applocalization.dart';
import 'themes/dimens.dart';

abstract class AbstractState<T extends StatefulWidget> extends State<T> {

  @override
  Widget build(BuildContext context) {
    return doBuild(context, AppLocalization.of(context), Dimens.of(context), Theme.of(context));
  }

  @protected
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme);
}

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