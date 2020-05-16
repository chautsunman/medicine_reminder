import 'package:meta/meta.dart';

import 'package:sqflite/sqflite.dart';

import 'NotificationHelper.dart';

class Helper {
  final Database db;
  final String photoPath;
  final NotificationHelper notification;

  Helper({
    @required this.db,
    @required this.photoPath,
    @required this.notification,
  });
}
