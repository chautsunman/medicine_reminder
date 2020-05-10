import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Notification.dart';

import 'obj/MedicationObj.dart';
import 'obj/ScheduleObj.dart';

class HomePage extends StatefulWidget {
  final String title;

  final Database db;
  final FlutterLocalNotificationsPlugin notifications;

  HomePage({Key key, this.title, this.db, this.notifications}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MedicationObj> medications;

  getMedications() async {
    final List<Map<String, dynamic>> medicationMaps = await widget.db.query('medication');
    final List<MedicationObj> medications = medicationMaps.map((map) {
      return MedicationObj.fromDbMap(map);
    }).toList();
    setState(() {
      this.medications = medications;
    });
  }

  refreshNotifications() async {
    final List<Map<String, dynamic>> scheduleRecords = await widget.db.rawQuery(
      'SELECT * FROM schedule INNER JOIN medication ON medication.id = schedule.medication_id'
    );

    final Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules = groupSchedules(scheduleRecords);

    await clearNotifications(widget.notifications);

    return addNotifications(widget.notifications, groupedSchedules);
  }

  onSaved() async {
    await refreshNotifications();

    getMedications();
  }

  onAdd() async {
    final res = await Navigator.pushNamed(
      context,
      '/details',
      arguments: null
    );

    if (res != null && res) {
      onSaved();
    }
  }

  onMedicationTap(idx) async {
    final res = await Navigator.pushNamed(
      context,
      '/details',
      arguments: medications[idx]
    );

    if (res != null && res) {
      onSaved();
    }
  }

  @override
  void initState() {
    super.initState();

    medications = [];

    getMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, idx) {
            return ListTile(
              title: Text(medications[idx].name),
              onTap: () {
                onMedicationTap(idx);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: onAdd,
      ),
    );
  }
}
