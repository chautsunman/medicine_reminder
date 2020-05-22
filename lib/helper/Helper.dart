import 'package:meta/meta.dart';

import 'package:sqflite/sqflite.dart';

import 'MedicationDbHelper.dart';
import 'NotificationHelper.dart';

class Helper {
  final Database db;
  final MedicationDbHelper medicationDbHelper;
  final String photoPath;
  final NotificationHelper notification;

  Helper({
    @required this.db,
    @required this.medicationDbHelper,
    @required this.photoPath,
    @required this.notification,
  });
}
