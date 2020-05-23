import 'package:sqflite/sqflite.dart';

class CheckInDbHelper {
  final Database db;

  CheckInDbHelper(this.db);

  getCheckIn() async {
    return await db.query('check_ins');
  }
}
