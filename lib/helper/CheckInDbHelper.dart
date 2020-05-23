import 'package:sqflite/sqflite.dart';

import '../obj/ScheduleLastCheckInObj.dart';

class CheckInDbHelper {
  final Database db;

  CheckInDbHelper(this.db);

  getCheckIn() async {
    return await db.query('check_ins');
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
