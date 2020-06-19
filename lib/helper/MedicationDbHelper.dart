import 'package:sqflite/sqflite.dart';

import '../obj/MedicationObj.dart';
import '../obj/ScheduleObj.dart';
import '../obj/ScheduleKey.dart';
import '../obj/ScheduleGroupObj.dart';
import '../obj/ScheduleMedicationObj.dart';
import '../obj/DateScheduleObj.dart';
import '../obj/DateSchedulesObj.dart';

import '../utils/DateTimeUtils.dart';

class MedicationDbHelper {
  final Database db;

  MedicationDbHelper(this.db);

  getMedication() async {
    return await db.query('medication');
  }

  getMedicationSchedules(int medicationId) async {
    return await db.rawQuery(
      '''
        SELECT GROUP_CONCAT(schedule_day, ',') AS schedule_days, schedule_group.schedule_time
        FROM schedule_medication
        INNER JOIN schedule_group ON schedule_group.id = schedule_medication.schedule_group_id
        WHERE schedule_medication.medication_id = ?
        AND schedule_group.active = 1
        GROUP BY schedule_group.schedule_time
        ORDER BY schedule_group.schedule_time ASC
      ''',
      [medicationId]
    );
  }

  saveMedication(MedicationObj medication, List<ScheduleObj> newSchedules, List<ScheduleObj> oldSchedules) async {
    await db.transaction((txn) async {
      int medicationId = medication.id;

      if (medication == null || medication.id == null) {
        print('Add medication.');
        medicationId = await txn.insert('medication', medication.toMap());
      } else {
        print('Update medication ${medication.id}');
        await txn.update(
          'medication',
          medication.toMap(),
          where: 'id = ?',
          whereArgs: [medication.id]
        );
      }

      print('Medication ID: $medicationId');

      var now = getSameUtcTimeOfNow();

      var schedulesBatch = txn.batch();

      Set<ScheduleKey> newScheduleKeys = Set<ScheduleKey>();
      newSchedules.forEach((newSchedule) {
        newScheduleKeys.addAll(newSchedule.getScheduleKeys());
      });
      print('Number of new schedule keys: ${newScheduleKeys.length}');
      Set<ScheduleKey> oldScheduleKeys = Set<ScheduleKey>();
      oldSchedules.forEach((oldSchedule) {
        oldScheduleKeys.addAll(oldSchedule.getScheduleKeys());
      });
      print('Number of old schedule keys: ${oldScheduleKeys.length}');

      List<ScheduleKey> schedulesToAdd = newScheduleKeys.difference(oldScheduleKeys).toList();
      print('Number of schedules to add: ${schedulesToAdd.length}');
      List<ScheduleKey> schedulesToRemove = oldScheduleKeys.difference(newScheduleKeys).toList();
      print('Number of schedules to remove: ${schedulesToRemove.length}');

      List<Map<String, dynamic>> latestScheduleGroupIdRecord = await txn.rawQuery('''
        SELECT CASE WHEN COUNT(*) > 0 THEN MAX(id) ELSE 0 END AS latest_schedule_group_id
        FROM schedule_group;
      ''');
      int newScheduleGroupId = (latestScheduleGroupIdRecord.length > 0)
          ? latestScheduleGroupIdRecord[0]['latest_schedule_group_id'] + 1
          : 1;
      print('New schedule group ID: $newScheduleGroupId');

      for (int i = 0; i < schedulesToAdd.length; i++) {
        print('Add new schedule $i. Day: ${schedulesToAdd[i].day}, Time: ${schedulesToAdd[i].time}');

        List<Map<String, dynamic>> sameScheduleGroupRecords = await txn.rawQuery(
          '''
            SELECT schedule_group.id
            FROM schedule_group
            INNER JOIN schedule_medication ON schedule_medication.schedule_group_id = schedule_group.id
            INNER JOIN medication ON medication.id = schedule_medication.medication_id
            WHERE
            schedule_group.schedule_day = ?
            AND schedule_group.schedule_time = ?
            AND schedule_medication.medication_id != ?
            AND schedule_group.active = 1
            AND medication.active = 1
          ''',
          [schedulesToAdd[i].day, schedulesToAdd[i].time, medicationId]
        );
        print('Number of other medications that are in the same schedule group: ${sameScheduleGroupRecords.length}');

        print('Add new schedule group $newScheduleGroupId.');
        schedulesBatch.insert(
          'schedule_group',
          ScheduleGroupObj.newGroup(newScheduleGroupId, schedulesToAdd[i].day, schedulesToAdd[i].time, now).toDbMap()
        );

        print('Add medication to new schedule group.');
        schedulesBatch.insert(
          'schedule_medication',
          ScheduleMedicationObj.newRecord(newScheduleGroupId, medicationId).toDbMap()
        );

        if (sameScheduleGroupRecords.length > 0) {
          int sameScheduleGroupId = sameScheduleGroupRecords[0]['id'];
          print('Add other medications that are in the same old schedule group $sameScheduleGroupId to new schedule group $newScheduleGroupId.');
          schedulesBatch.execute(
            '''
              INSERT INTO schedule_medication (schedule_group_id, medication_id)
              SELECT ?, medication_id
              FROM schedule_medication
              WHERE schedule_group_id = ?
            ''',
            [newScheduleGroupId, sameScheduleGroupId]
          );

          print('Set old schedule group of other medications to not active.');
          schedulesBatch.update(
            'schedule_group',
            {
              'active': 0,
              'non_active_time': now.millisecondsSinceEpoch
            },
            where: 'id = ?',
            whereArgs: [sameScheduleGroupId]
          );
        }

        newScheduleGroupId++;
      }

      for (int i = 0; i < schedulesToRemove.length; i++) {
        print('Remove old schedule $i. Day: ${schedulesToRemove[i].day}, Time: ${schedulesToRemove[i].time}');

        List<Map<String, dynamic>> oldScheduleGroupIdRecords = await txn.rawQuery(
          '''
            SELECT schedule_group.id
            FROM schedule_group
            INNER JOIN schedule_medication ON schedule_medication.schedule_group_id = schedule_group.id
            WHERE
            schedule_group.schedule_day = ?
            AND schedule_group.schedule_time = ?
            AND schedule_medication.medication_id = ?
            AND schedule_group.active = 1
            LIMIT 1
          ''',
          [schedulesToRemove[i].day, schedulesToRemove[i].time, medicationId]
        );

        if (oldScheduleGroupIdRecords.length > 0) {
          int oldScheduleGroupId = oldScheduleGroupIdRecords[0]['id'];
          print('Old schedule group: $oldScheduleGroupId');

          List<Map<String, dynamic>> oldScheduleGroupMedicationsCountRecords = await txn.rawQuery(
            '''
              SELECT COUNT(*) AS medications_count
              FROM schedule_medication
              WHERE schedule_group_id = ? AND medication_id != ?
            ''',
            [oldScheduleGroupId, medicationId]
          );

          int oldScheduleGroupMedicationsCount = oldScheduleGroupMedicationsCountRecords[0]['medications_count'];
          print('Number of other medications that are in the same old schedule group: $oldScheduleGroupMedicationsCount');

          if (oldScheduleGroupMedicationsCount > 0) {
            print('Add new schedule group $newScheduleGroupId.');
            schedulesBatch.insert(
              'schedule_group',
              ScheduleGroupObj.newGroup(newScheduleGroupId, schedulesToRemove[i].day, schedulesToRemove[i].time, now).toDbMap()
            );

            print('Add other medications that are in the same old schedule group $oldScheduleGroupId to new schedule group $newScheduleGroupId.');
            schedulesBatch.execute(
              '''
                INSERT INTO schedule_medication (schedule_group_id, medication_id)
                SELECT ?, medication_id
                FROM schedule_medication
                WHERE schedule_group_id = ?
                AND medication_id != ?
              ''',
              [newScheduleGroupId, oldScheduleGroupId, medicationId]
            );

            newScheduleGroupId++;
          } else {
            print('Do not need to add new schedule group as removed medication is the only medication in the old schedule group.');
          }

          print('Set old schedule group of other medications to not active.');
          schedulesBatch.update(
            'schedule_group',
            {
              'active': 0,
              'non_active_time': now.millisecondsSinceEpoch
            },
            where: 'id = ?',
            whereArgs: [oldScheduleGroupId]
          );
        }
      }

      schedulesBatch.commit(noResult: true);
    });
  }

  Future<DateScheduleObj> getNextSchedule() async {
    final DateTime now = DateTime.now();
    final int nowWeekDay = now.weekday % 7;
    final int nowTime = ((now.hour * 60 + now.minute) * 60 + now.second) * 1000 + now.millisecond;
    List<Map<String, dynamic>> resMaps = await db.rawQuery(
      '''
        SELECT
        schedule_group.*,
        COUNT(*) AS medications_count,
        CASE
          WHEN schedule_group.schedule_day = ? THEN CASE WHEN schedule_group.schedule_time > ? THEN schedule_group.schedule_day ELSE schedule_group.schedule_day + 7 END
          WHEN schedule_group.schedule_day < ? THEN schedule_group.schedule_day + 7
          ELSE schedule_group.schedule_day
        END AS next_schedule_day
        FROM schedule_group
        INNER JOIN schedule_medication ON schedule_medication.schedule_group_id = schedule_group.id
        INNER JOIN medication ON medication.id = schedule_medication.medication_id
        WHERE
        schedule_group.active = 1
        AND medication.active = 1
        GROUP BY schedule_group.id
        ORDER BY next_schedule_day ASC, schedule_group.schedule_time ASC
      ''',
      [nowWeekDay, nowTime, nowWeekDay]
    );
    if (resMaps.length <= 0) {
      return null;
    }
    final int scheduleGroupId = resMaps[0]['id'];
    final int scheduleDay = resMaps[0]['schedule_day'];
    final int scheduleTime = resMaps[0]['schedule_time'];
    final int medicationsCount = resMaps[0]['medications_count'];
    final int nextScheduleDay = resMaps[0]['next_schedule_day'];
    DateTime nextScheduleDate = DateTime(now.year, now.month, now.day)
        .add(Duration(days: nextScheduleDay - nowWeekDay))
        .add(Duration(milliseconds: scheduleTime));
    return DateScheduleObj(
      nextScheduleDate,
      scheduleGroupId,
      medicationsCount
    );
  }

  Future<List<DateSchedulesObj>> getDateSchedules(DateTime date) async {
    final int day = date.weekday % 7;

    List<Map<String, dynamic>> resMaps = await db.rawQuery(
      '''
        SELECT
        schedule_group.id AS schedule_group_id,
        schedule_group.schedule_day AS schedule_group_schedule_day,
        schedule_group.schedule_time AS schedule_group_schedule_time,
        medication.id AS medication_id,
        medication.name AS medication_name
        FROM schedule_group
        INNER JOIN schedule_medication ON schedule_medication.schedule_group_id = schedule_group.id
        INNER JOIN medication ON medication.id = schedule_medication.medication_id
        WHERE
        schedule_group.schedule_day = ?
        AND schedule_group.active = 1
        AND medication.active = 1
        ORDER BY schedule_group.schedule_time ASC
      ''',
      [day]
    );

    if (resMaps == null) {
      return [];
    }

    return DateSchedulesObj.groupDateSchedulesFromDbMap(resMaps);
  }

  Future<DateTime> getLastScheduleChange() async {
    final List<Map<String, dynamic>> resMaps = await db.rawQuery(
      '''
        SELECT MAX(active_time) AS last_schedule_group_active_time
        FROM schedule_group
        WHERE active = 1
      '''
    );

    if (resMaps == null || resMaps.length == 0) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return DateTime.fromMillisecondsSinceEpoch(resMaps[0]['last_schedule_group_active_time'], isUtc: true);
  }
}
