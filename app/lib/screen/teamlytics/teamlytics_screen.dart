import 'package:app/data.dart';
import 'package:app/screen/teamlytics/replay_entries.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TeamlyticsScreen extends StatefulWidget {
  const TeamlyticsScreen({super.key});

  @override
  _TeamlyticsScreenState createState() => _TeamlyticsScreenState();
}

class _TeamlyticsScreenState extends State<TeamlyticsScreen> {
  int _selectedIndex = 0; // To track the selected tab
  List<Replay> replays = [];


  @override
  Widget build(BuildContext context) {
    // Determine if the app is running on the web
    final bool isWeb = kIsWeb;


    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: isWeb
            ? AppBar(
          title: const Text("Pokemon SD Teamlytics"),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              Tab(text: "Home"),
              Tab(text: "Replay Entries"),
              Tab(text: "Usage stats"),
            ],
          ),
        )
            : null,
        body: TabBarView(
          children: [
            Center(child: Text("Content for Tab 1")),
            Center(child: ReplayEntriesComponent(replays: replays, onAddReplay: _onAddReplay, onRemoveReplay: _onRemoveReplay,)),
            Center(child: Text("Content for Tab 3")),
          ],
        ),
        bottomNavigationBar: !isWeb
            ? BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_one),
              label: "Tab 1",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_two),
              label: "Tab 2",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_3),
              label: "Tab 3",
            ),
          ],
        )
            : null,
      ),
    );
  }

  void _onAddReplay(Replay replay) {
    setState(() {
      replays.add(replay);
    });
  }

  void _onRemoveReplay(Replay replay) {
    setState(() {
      replays.remove(replay);
    });
  }
}