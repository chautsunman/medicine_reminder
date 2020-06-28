import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'App.dart';
import 'InitPage.dart';

import 'helper/Helper.dart';
import 'helper/MedicationDbHelper.dart';
import 'helper/CheckInDbHelper.dart';
import 'helper/NotificationHelper.dart';
import 'helper/DbCreateHelper.dart';

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

  Future<NotificationHelper> initNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('icon');
    // var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, null);
    final bool initRes = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onNotificationOpen,
    );
    if (initRes) {
      print('Notifications initialized.');
      return NotificationHelper(flutterLocalNotificationsPlugin);
    }
    return null;
  }

  onNotificationOpen(String payload) async {
    print('App opened from notification, payload: $payload');

    if (payload == null) {
      return;
    }

    Map<String, dynamic> data = jsonDecode(payload);
  }

  init() async {
    final dbPath = join(await getDatabasesPath(), 'medication.db');
    final dbFuture = openDatabase(
      dbPath,
      onCreate: onDbCreate,
      onUpgrade: onDbUpgrade,
      onOpen: (db) async {
        final int version = await db.getVersion();
        print('DB opened. Version: $version');
      },
      version: 6,
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
      initFutures = Future.wait([dbFuture, photoPathFuture, initNotification()]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initFutures,
      builder: (context, initFuturesSnapshot) {
        String initialRoute = (initFuturesSnapshot.hasData) ? '/' : '/init';
        if (initFuturesSnapshot.hasData) {
          if (initFuturesSnapshot.data[2] == null) {
            initialRoute = '/init';
          }
        }

        Helper helper;
        if (initFuturesSnapshot.hasData) {
          helper = Helper(
            db: initFuturesSnapshot.data[0],
            medicationDbHelper: MedicationDbHelper(initFuturesSnapshot.data[0]),
            checkInDbHelper: CheckInDbHelper(initFuturesSnapshot.data[0]),
            photoPath: initFuturesSnapshot.data[1],
            notification: initFuturesSnapshot.data[2],
          );
        }

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
                    return App(
                      title: 'Medicine Reminder',
                      helper: helper,
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
