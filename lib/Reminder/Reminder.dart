import 'package:flutter/material.dart';

import '../helper/NotificationHelper.dart';
import '../helper/Helper.dart';

import '../obj/MedicationObj.dart';
import '../obj/ScheduleKey.dart';

class Reminder extends StatefulWidget {
  final String title;

  final Helper helper;

  Reminder({Key key, @required this.title, @required this.helper}) : super(key: key);

  @override
  _ReminderState createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  List<MedicationObj> medications;

  getMedications() async {
    final List<Map<String, dynamic>> medicationMaps = await widget.helper.medicationDbHelper.getMedication();
    final List<MedicationObj> medications = medicationMaps.map((map) {
      return MedicationObj.fromDbMap(map);
    }).toList();
    setState(() {
      this.medications = medications;
    });
  }

  refreshNotifications() async {
    final List<Map<String, dynamic>> scheduleRecords = await widget.helper.db.rawQuery('''
      SELECT *
      FROM schedule_group
      INNER JOIN schedule_medication ON schedule_medication.schedule_group_id = schedule_group.id
      INNER JOIN medication ON medication.id = schedule_medication.medication_id
      WHERE schedule_group.active = 1 AND medication.active = 1
    ''');

    final Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules = groupSchedules(scheduleRecords);

    await widget.helper.notification.clearNotifications();

    return widget.helper.notification.addNotifications(groupedSchedules);
  }

  onSaved() async {
    await refreshNotifications();

    getMedications();
  }

  onAdd() async {
    final res = await Navigator.pushNamed(
      context,
      'reminder/details',
      arguments: null
    );

    if (res != null && res) {
      onSaved();
    }
  }

  onMedicationTap(idx) async {
    final res = await Navigator.pushNamed(
      context,
      'reminder/details',
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
