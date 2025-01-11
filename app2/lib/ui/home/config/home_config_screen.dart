import 'package:app2/ui/core/widgets.dart';
import 'package:app2/ui/home/config/home_config_viewmodel.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';

import '../../core/localization/applocalization.dart';
import '../../core/themes/dimens.dart';


class HomeConfigComponent extends StatefulWidget {
  final HomeViewModel homeViewModel;
  final HomeConfigViewModel viewModel;

  const HomeConfigComponent({super.key, required this.homeViewModel, required this.viewModel});


  @override
  _HomeConfigComponentState createState() => _HomeConfigComponentState();
}

class _HomeConfigComponentState extends AbstractState<HomeConfigComponent> {

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36, horizontal: 128),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(localization.showdownNames, style: theme.textTheme.titleLarge,),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: widget.viewModel.sdNameController,
                  onSubmitted: (value) {
                    widget.homeViewModel.addSdName(value);
                    widget.viewModel.sdNameController.clear();
                  },
                  decoration: InputDecoration(
                    labelText: localization.addSdName,
                 //   border: OutlineInputBorder(),
                  ),
                )
                ,
              )
            ],
          ),
          Row(
            children: [
              ...widget.homeViewModel.sdNames.map((sdName) {
                return Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Text("- $sdName"),
                      IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.homeViewModel.removeSdName(sdName))
                    ],));
              })
            ],
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          // pokepaste
          ...pokepasteWidget(localization, theme)
        ],
      ),
    );
  }

  List<Widget> pokepasteWidget(AppLocalization localization, ThemeData theme) {
    final title = Text(localization.pokepasteUrl, style: theme.textTheme.titleLarge,);
    if (widget.homeViewModel.pokepasteUrl == null) {
      return [
        Row(
          children: [
            title,
            Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            SizedBox(
              width: 450,
              // TODO change pokepaste URL to pokepaste content. we cannot fetch pokepaste URL due to CORS.
              //  this should be a big multiline TextField
              child: TextField(
                controller: widget.viewModel.pokepasteUrlController,
                onSubmitted: (value) {
                  widget.homeViewModel.addSdName(value);
                  widget.viewModel.sdNameController.clear();
                },
                decoration: InputDecoration(
                  labelText: localization.enterUrl,
                  border: OutlineInputBorder(),
                ),
              )
              ,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
            OutlinedButton(
              onPressed: () => widget.viewModel.loadPokepaste(),
              child: Text(localization.load,),
            )
          ],
        )
      ];
    }
    return [];
  }
}