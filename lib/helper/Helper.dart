import 'package:meta/meta.dart';

import 'package:sqflite/sqflite.dart';

import 'MedicationDbHelper.dart';
import 'CheckInDbHelper.dart';
import 'NotificationHelper.dart';

class Helper {
  final Database db;
  final MedicationDbHelper medicationDbHelper;
  final CheckInDbHelper checkInDbHelper;
  final String photoPath;
  final NotificationHelper notification;

  Helper({
    @required this.db,
    @required this.medicationDbHelper,
    @required this.checkInDbHelper,
    @required this.photoPath,
    @required this.notification,
  });
}
