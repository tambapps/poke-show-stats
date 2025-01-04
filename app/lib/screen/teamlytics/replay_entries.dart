import 'package:app/data.dart';
import 'package:app/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd_replay_parser/sd_replay_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class ReplayEntriesComponent extends StatefulWidget {
  final List<Replay> replays;
  final Function(Replay) onAddReplay;
  final Function(Replay) onRemoveReplay;

  const ReplayEntriesComponent({
    super.key,
    required this.replays,
    required this.onAddReplay,
    required this.onRemoveReplay,
  });

  @override
  _ReplayEntriesComponentState createState() => _ReplayEntriesComponentState();
}

class _ReplayEntriesComponentState extends State<ReplayEntriesComponent> {
  final SdReplayParser replayParser = SdReplayParser();

  bool isLoading = false; // State for tracking the loading process
  final TextEditingController _addReplayURIController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rowTitleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0)),
    if (isLoading) LinearProgressIndicator(
      backgroundColor: Colors.grey[300], // Background color
      valueColor: AlwaysStoppedAnimation(Colors.blue), // Progress color
      minHeight: 2.0, // Height of the progress bar
    ),
        SingleChildScrollView(
          child: Column(children: [
            if (widget.replays.isNotEmpty)
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                0: FractionColumnWidth(0.1),
                1: FractionColumnWidth(0.3),
                2: FractionColumnWidth(0.3),
                3: FractionColumnWidth(0.2),
                4: FractionColumnWidth(0.1),
              },
              children: [
                TableRow(children: [
                  Center(child: Text('', style: rowTitleTextStyle,),),
                  Center(child: Text('Replay URL', style: rowTitleTextStyle),),
                  Center(child: Text('Opposing Team', style: rowTitleTextStyle),),
                  Center(child: Text('Notes', style: rowTitleTextStyle),),
                  Center(child: Text('', style: rowTitleTextStyle,),),
                ]),
               ...widget.replays.asMap().entries.map((entry) {
                 final number = entry.key + 1;
                 final Replay replay = entry.value;
                 final replayLink = replay.uri.toString().replaceFirst('.json', '');
                 return TableRow(
                   children: [
                     Center(child: Text(number.toString()),),
                     Center(
                       child: TextButton(
                         onPressed: () => _openLink(replayLink),
                         child: Text(replayLink, overflow: TextOverflow.ellipsis, style: TextStyle(
                           color: Colors.blue,
                           decoration: TextDecoration.underline,
                         ),),
                       ),),
                     Center(child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                       children: replay.data.player1.team
                           .map((pokemon) =>
                           Padding(padding: EdgeInsets.symmetric(horizontal: 4), child:
                           Tooltip(message: pokemon, child:
                           Image(width: pokemonLogoSize, height: pokemonLogoSize, fit: BoxFit.contain,
                               image: AssetImage("pokemon-sprites/${pokemon.replaceAll(' ', '-')}.png"),
                               errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                 return Icon(Icons.catching_pokemon, size: pokemonLogoSize);
                               }),),))
                           .toList(),
                     ),),
                     Center(child: Text(replay.notes ?? ''),),
                     Center(child: IconButton(icon: Icon(Icons.cancel_outlined), iconSize: 16, onPressed: () => widget.onRemoveReplay(replay))),
                   ],
                 );
               })
              ],
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      // TODO there is a problem when hovering on it targetElement == domElement... should be fixed in flutter release 3.28
                      child: TextField(
                        controller: _addReplayURIController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Replay URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _addReplay(_addReplayURIController.text),
                      child: const Text('Add'),
                    ),
                  ],
                ))
          ],),
        ),
      ],
    );
  }

  void _openLink(String link) async {
    final Uri uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens browser or Chrome Tabs on mobile
        webOnlyWindowName: '_blank',         // Opens a new tab on the web
      );
    } else {
      throw "Could not launch $link";
    }
  }

  Future<Replay> _fetchReplay(String input) async {
    Uri uri = Uri.parse(input.endsWith('.json') ? input : "$input.json");
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Error while fetching replay (response code ${response.statusCode})");
    }
    final data = jsonDecode(response.body);
    SdReplayData replayData = replayParser.parse(data);
    return Replay(uri: uri, data: replayData);
  }

  void _addReplay(String input) {
    if (isLoading) return;
    _addReplayURIController.clear();
    setState(() {
      isLoading = true;
    });
    _fetchReplay(input)
        .then(widget.onAddReplay)
        .catchError((error) {
      setState(() {
        isLoading = false;
      });
      String errorMessage;
      if (error is FormatException) {
        errorMessage = "Invalid URI";
      } else {
        errorMessage = error.message;
      }
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    })
    .then((_) => setState(() => (isLoading = false)));
  }
}
