

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

  final linkTextStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline, // Underline effect
  );

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
            Padding(padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0), child: _aboutMeText(),),
            const SizedBox(height: 64.0,),
            Align(alignment: Alignment.topCenter, child: Text("About the app", style: theme.textTheme.titleLarge,),),
            Padding(padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0), child: _aboutTheAppText(),),
            const SizedBox(height: 64.0,),
            Align(alignment: Alignment.topCenter, child: Text("Credits", style: theme.textTheme.titleLarge,),),
            Padding(padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0), child: _creditsText(),),
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
            style: linkTextStyle,
            recognizer: TapGestureRecognizer()..onTap = () => openLink("https://x.com/jarmanVGC"),
          ),
          TextSpan(
            text: " and ",
          ),
          TextSpan(
            text: "tambapps",
            style: linkTextStyle,
            recognizer: TapGestureRecognizer()..onTap = () => openLink("https://github.com/tambapps/"),
          ),
        ],
      ),
      textAlign: TextAlign.justify,
    );
  }


  Widget _aboutTheAppText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("I built this app because I wanted one single UI in which I could keep track of how I use a team and take notes to improve myself and know how to handle different match-ups.",
          textAlign: TextAlign.justify,),
        Text.rich(
          TextSpan(
            text: "",
            children: [
              TextSpan(
                text: "This app ",
              ),
              TextSpan(
                  text: "collects no data",
                  style: TextStyle(fontWeight: FontWeight.bold)
              ),
              TextSpan(
                text: ".",
              ),
              TextSpan(
                text: " All data is saved on your local storage (of your web browser or mobile phone).",
              ),
              TextSpan(
                text: " You can check the source code of this app ",
              ),
              TextSpan(
                text: "here",
                style: linkTextStyle,
                recognizer: TapGestureRecognizer()..onTap = () => openLink("https://github.com/tambapps/pokemon-teamlytics/"),
              ),
              TextSpan(
                text: ".",
              )
            ],
          ),
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _creditsText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: "",
            children: [
              TextSpan(
                text: "jormxdos",
                style: linkTextStyle,
                recognizer: TapGestureRecognizer()..onTap = () => openLink("https://www.deviantart.com/jormxdos"),
              ),
              TextSpan(
                text: " to have designed the tera type logos.",
              ),
            ],
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 8.0,),
        Text("Shoutout to me, to have developed the whole app by myself from scratch.", textAlign: TextAlign.justify,)
      ],);
  }
}