import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';


class HomeConfigComponent extends StatefulWidget {
  final HomeViewModel homeViewModel;

  const HomeConfigComponent({super.key, required this.homeViewModel});


  @override
  _HomeConfigComponentState createState() => _HomeConfigComponentState();
}

class _HomeConfigComponentState extends AbstractState<HomeConfigComponent> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 36, horizontal: 128),
          child: Align(alignment: Alignment.topLeft,child: Text(localization.showdownNames, style: theme.textTheme.titleMedium,),),),
        Row(
          children: [
            ...widget.homeViewModel.sdNames.map((sdName) {
              return Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("- $sdName"));
            })
          ],
        )
      ],
    );
  }
}