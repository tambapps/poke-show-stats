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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: TabBar(
            onTap: (index) => widget.viewModel.onTabSelected(index),
            tabs: [
              Tab(text: localization.home),
              Tab(text: localization.replayEntries),
              Tab(text: localization.usageStats),
            ],
          ),
          body: TabBarView(
            children: [
              Center(child: Text("Content for Tab 1")),
              Center(child: Text("Content for Tab 2")),
              Center(child: Text("Content for Tab 3")),
            ],
          )
      ),
    );
  }
}