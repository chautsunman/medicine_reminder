import 'dart:math';

import 'package:sqflite/sqflite.dart';

onDbCreate(Database db, int version) async {
  await db.transaction((txn) async {
    var batch = txn.batch();
    batch.execute('''
      CREATE TABLE medication (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        photo_file_name VARCHAR(255),
        active INTEGER DEFAULT 1
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS schedule_group (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_day INTEGER,
        schedule_time INTEGER,
        active INTEGER DEFAULT 1
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS schedule_medication (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_group_id INTEGER,
        medication_id INTEGER,
        FOREIGN KEY(schedule_group_id) REFERENCES schedule_group(id),
        FOREIGN KEY(medication_id) REFERENCES medication(id)
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_group_id INTEGER,
        check_in_time INTEGER NOT NULL
      )
    ''');
    await batch.commit();
  });
}

onDbUpgrade(Database db, int oldVersion, int newVersion) async {
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
  if (oldVersion <= 3) {
    await db.transaction((txn) async {
      var createTableBatch = txn.batch();
      createTableBatch.execute('''
        CREATE TABLE IF NOT EXISTS schedule_group (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          schedule_day INTEGER,
          schedule_time INTEGER,
          active INTEGER DEFAULT 1
        )
      ''');
      createTableBatch.execute('''
        CREATE TABLE IF NOT EXISTS schedule_medication (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          schedule_group_id INTEGER,
          medication_id INTEGER,
          FOREIGN KEY(schedule_group_id) REFERENCES schedule_group(id),
          FOREIGN KEY(medication_id) REFERENCES medication(id)
        )
      ''');
      createTableBatch.execute('''
        CREATE TABLE IF NOT EXISTS check_ins (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          schedule_group_id INTEGER,
          check_in_time INTEGER NOT NULL
        )
      ''');
      await createTableBatch.commit();

      var alterTableBatch = txn.batch();
      alterTableBatch.execute('ALTER TABLE medication ADD active INTEGER DEFAULT 1');
      await alterTableBatch.commit();

      var migrateDataBatch = txn.batch();

      final List<Map<String, dynamic>> scheduleRecords = await txn.rawQuery(
        'SELECT *, medication.id AS medication_id FROM schedule INNER JOIN medication ON medication.id = schedule.medication_id'
      );

      Map<String, Map<String, dynamic>> scheduleGroups = {};
      Map<String, List<Map<String, dynamic>>> groupedSchedules = {};
      int scheduleGroupId = 1;
      scheduleRecords.forEach((record) {
        int scheduleDay = record['schedule_day'];
        int scheduleTime = record['schedule_time'];
        int scheduleDayTemp = scheduleDay;
        for (int dayIdx = 6; dayIdx >= 0; dayIdx--) {
          if (scheduleDayTemp >= pow(2, dayIdx)) {
            String scheduleKey = '${dayIdx}_$scheduleTime';
            if (!groupedSchedules.containsKey(scheduleKey)) {
              scheduleGroups[scheduleKey] = {
                'id': scheduleGroupId,
                'schedule_day': dayIdx,
                'schedule_time': scheduleTime
              };
              scheduleGroupId++;
              groupedSchedules[scheduleKey] = [];
            }
            groupedSchedules[scheduleKey].add({
              'schedule_group_id': scheduleGroups[scheduleKey]['id'],
              'medication_id': record['medication_id']
            });
            scheduleDayTemp -= pow(2, dayIdx);
          }
        }
      });

      scheduleGroups.forEach((_, scheduleGroup) {
        migrateDataBatch.insert('schedule_group', scheduleGroup);
      });

      groupedSchedules.forEach((_, schedules) {
        schedules.forEach((schedule) {
          migrateDataBatch.insert('schedule_medication', schedule);
        });
      });

      await migrateDataBatch.commit();

      var dropTableBatch = txn.batch();
      dropTableBatch.execute('DROP TABLE IF EXISTS schedule');
      await dropTableBatch.commit();
    });
  }
}
