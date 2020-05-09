import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'HomePage.dart';
import 'DetailsPage.dart';
import 'InitPage.dart';

import 'obj/MedicationObj.dart';

void main() => runApp(MedicineReminderApp());

class MedicineReminderApp extends StatefulWidget {
  @override
  _MedicineReminderAppState createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  Future<List<dynamic>> initFutures;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    final dbPath = join(await getDatabasesPath(), 'medication.db');
    final dbFuture = openDatabase(
      dbPath,
      onCreate: (db, version) async {
        var batch = db.batch();
        batch.execute('''
          CREATE TABLE medication (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(255) NOT NULL,
            photo_file_name VARCHAR(255)
          )
        ''');
        batch.execute('''
          CREATE TABLE schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medication_id INTEGER,
            schedule_day INTEGER,
            schedule_time INTEGER,
            FOREIGH KEY(medication_id) REFERENCES medication(id)
          )
        ''');
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion <= 1) {
          var batch = db.batch();
          batch.execute('ALTER TABLE medication ALTER COLUMN name VARCHAR(255) NOT NULL');
          batch.execute('ALTER TABLE medication ADD photo_file_name VARCHAR(255)');
          await batch.commit();
        }
        if (oldVersion <= 2) {
          var batch = db.batch();
          batch.execute('''
            CREATE TABLE IF NOT EXISTS schedule (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              medication_id INTEGER,
              schedule_day INTEGER,
              schedule_time INTEGER,
              FOREIGN KEY(medication_id) REFERENCES medication(id)
            )
          ''');
          await batch.commit();
        }
      },
      onOpen: (db) {
        print('DB opened.');
      },
      version: 3,
    );

    final localPathFuture = getApplicationDocumentsDirectory().then((dir) => dir.path);

    final photoPathFuture = localPathFuture.then((localPath) async {
      final photoPath = '$localPath/photos';
      final photoDir = Directory(photoPath);
      final photoDirExists = await photoDir.exists();
      if (!photoDirExists) {
        photoDir.create();
      }
      return photoPath;
    });

    setState(() {
      initFutures = Future.wait([dbFuture, photoPathFuture]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initFutures,
      builder: (context, initFuturesSnapshot) {
        final initialRoute = (initFuturesSnapshot.hasData) ? '/' : '/init';

        return MaterialApp(
          key: Key(initialRoute),
          title: 'Medicine Reminder',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          initialRoute: initialRoute,
          onGenerateRoute: (settings) {
            if (initFuturesSnapshot.hasData) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  builder: (context) {
                    return HomePage(
                      title: 'Medicine Reminder',
                      db: initFuturesSnapshot.data[0],
                    );
                  },
                );
              } else if (settings.name == '/details') {
                return MaterialPageRoute(
                  builder: (context) {
                    final MedicationObj medication = settings.arguments;

                    return DetailsPage(
                      medication: medication,
                      db: initFuturesSnapshot.data[0],
                      photoPath: initFuturesSnapshot.data[1],
                    );
                  },
                );
              }
            }

            return MaterialPageRoute(
              builder: (context) {
                return InitPage();
              },
            );
          },
        );
      },
    );
  }
}
