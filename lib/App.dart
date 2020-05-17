import 'package:flutter/material.dart';

import 'ReminderPage.dart';
import 'CheckInPage.dart';

import 'Helper.dart';

class App extends StatefulWidget {
  final String title;

  final Helper helper;

  App({
    Key key,
    @required this.title,
    @required this.helper
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _navigationIdx = 0;

  onNavigationTap(int idx) {
    setState(() {
      _navigationIdx = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      ReminderPage(
        title: widget.title,
        helper: widget.helper,
      ),
      CheckInPage(
        title: widget.title,
        helper: widget.helper,
      ),
    ];

    return Scaffold(
      body: pages[_navigationIdx],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            title: Text('Reminder'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            title: Text('Check In'),
          ),
        ],
        currentIndex: _navigationIdx,
        onTap: onNavigationTap,
        selectedItemColor: Colors.amber,
      ),
    );
  }
}
