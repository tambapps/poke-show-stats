

import 'package:app2/ui/core/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../data/services/pokemon_resource_service.dart';
import '../../core/localization/applocalization.dart';
import '../../core/widgets.dart';
import '../../core/themes/dimens.dart';
import 'about_viewmodel.dart';



class AboutScreen extends StatefulWidget {

  final AboutViewModel viewModel;

  const AboutScreen({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _AboutScreenState();
}


class _AboutScreenState extends AbstractScreenState<AboutScreen> {

  @override
  AboutViewModel get viewModel => widget.viewModel;

  @override
  PokemonResourceService get pokemonResourceService => viewModel.pokemonResourceService;


  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Scaffold(
        body: SingleChildScrollView(child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32.0,),
            Align(alignment: Alignment.topCenter, child: Text("About me", style: theme.textTheme.titleLarge,),),
            Padding(padding: EdgeInsets.only(left: 16.0, top: 16.0), child: _aboutMeText(),),
            const SizedBox(height: 64.0,),
            Align(alignment: Alignment.topCenter, child: Text("Credits", style: theme.textTheme.titleLarge,),),
            Padding(padding: EdgeInsets.only(left: 16.0, top: 16.0), child: _creditsText(),),
        ],),));
  }

  Widget _aboutMeText() {
    return Text.rich(
      TextSpan(
        text: "",
        children: [
          TextSpan(
            text: "I am a french Pokemon VGC player and a developer, known by the pseudos ",
          ),
          TextSpan(
            text: "jarman",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, // Underline effect
            ),
            recognizer: TapGestureRecognizer()..onTap = () => openLink("https://x.com/jarmanVGC"),
          ),
          TextSpan(
            text: " and ",
          ),
          TextSpan(
            text: "tambapps",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, // Underline effect
            ),
            recognizer: TapGestureRecognizer()..onTap = () => openLink("https://github.com/tambapps/"),
          ),
          TextSpan(
            text: "\n",
          ),
          TextSpan(
            text: "You can check the source code of this app ",
          ),
          TextSpan(
            text: "here",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, // Underline effect
            ),
            recognizer: TapGestureRecognizer()..onTap = () => openLink("https://github.com/tambapps/pokemon-teamlytics/"),
          )
        ],
      ),
    );
  }
  Widget _creditsText() {
    return Row(children: [
      InkWell(
        onTap: () => openLink("https://www.deviantart.com/jormxdos"),
        child: Text(
          "jormxdos",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline, // Underline effect like a hyperlink
          ),
        ),
      ),
      Text(" to have designed the tera type logos")
    ],);
  }
}