import 'package:flutter/material.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'HomePage.dart';
import 'DetailsPage.dart';
import 'InitPage.dart';

void main() => runApp(MedicineReminderApp());

class MedicineReminderApp extends StatefulWidget {
  @override
  _MedicineReminderAppState createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  Future<Database> dbFuture;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    final dbPath = join(await getDatabasesPath(), 'medication.db');

    setState(() {
      dbFuture = openDatabase(
        dbPath,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE medication (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255))');
        },
        version: 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dbFuture,
      builder: (context, dbSnapshot) {
        final initialRoute = (dbSnapshot.hasData) ? '/' : '/init';

        return MaterialApp(
          key: Key(initialRoute),
          title: 'Medicine Reminder',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          initialRoute: initialRoute,
          routes: {
            '/': (context) => HomePage(title: 'Medicine Reminder'),
            '/add': (context) => DetailsPage(db: dbSnapshot.data),
            '/init': (context) => InitPage(),
          },
        );
      },
    );
  }
}
