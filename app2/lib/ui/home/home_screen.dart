import 'package:app2/ui/core/widgets.dart';
import 'package:flutter/material.dart';

import '../core/localization/applocalization.dart';
import '../core/themes/dimens.dart';
import 'home_viewmodel.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractState<HomeScreen> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                localization.home,
              ),
            ],
          ),
        )
    );
  }
}