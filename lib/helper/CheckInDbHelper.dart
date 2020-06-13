import 'package:sqflite/sqflite.dart';

import '../obj/ScheduleGroupObj.dart';
import '../obj/ScheduleLastCheckInObj.dart';
import '../obj/CheckInObj.dart';

import '../utils/DateTimeUtils.dart';

class CheckInDbHelper {
  final Database db;

  CheckInDbHelper(this.db);

  Future<bool> checkIn(DateTime checkInDate, ScheduleGroupObj scheduleObj) async {
    final int numberOfInsertedRecords = await db.insert('check_ins', {
      'schedule_group_id': scheduleObj.id,
      'medication_date': getUtcDateStartFromLocalDate(checkInDate).millisecondsSinceEpoch,
      'check_in_time': getSameUtcTimeOfNow().millisecondsSinceEpoch
    });

    return numberOfInsertedRecords > 0;
  }

  Future<List<CheckInObj>> getDateCheckIns(DateTime date) async {
    final List<Map<String, dynamic>> resMaps = await db.query(
      'check_ins',
      where: 'medication_date = ?',
      whereArgs: [getUtcDateStartFromLocalDate(date).millisecondsSinceEpoch]
    );

    if (resMaps == null || resMaps.length == 0) {
      return [];
    }

    return resMaps.map((resMap) => CheckInObj.fromDbMap(resMap)).toList();
  }

  Future<List<CheckInObj>> getCheckIn() async {
    final List<Map<String, dynamic>> resMaps = await db.query('check_ins');

    if (resMaps == null || resMaps.length == 0) {
      return [];
    }

    return resMaps.map((resMap) => CheckInObj.fromDbMap(resMap)).toList();
  }

  Future<List<ScheduleLastCheckInObj>> getLastCheckIns() async {
    List<Map<String, dynamic>> resMaps = await db.rawQuery('''
      SELECT
      schedule_group.schedule_day, schedule_group.schedule_time, schedule_group.active_time,
      schedule_group_last_check_in_medication.last_check_in_time
      FROM schedule_group
      LEFT JOIN (
        SELECT schedule_group_id, MAX(medication_date) AS last_check_in_time
        FROM check_ins
        GROUP BY schedule_group_id
      ) AS schedule_group_last_check_in_medication
      ON schedule_group_last_check_in_medication.schedule_group_id = schedule_group.id
      WHERE schedule_group.active = 1
    ''');
    return resMaps.map((resMap) => ScheduleLastCheckInObj.fromDbMap(resMap)).toList();
  }
}
