import 'package:flutter/material.dart';

import 'NotificationHelper.dart';
import 'Helper.dart';

import 'obj/MedicationObj.dart';
import 'obj/ScheduleObj.dart';

class HomePage extends StatefulWidget {
  final String title;

  final Helper helper;

  HomePage({Key key, @required this.title, @required this.helper}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MedicationObj> medications;

  getMedications() async {
    final List<Map<String, dynamic>> medicationMaps = await widget.helper.db.query('medication');
    final List<MedicationObj> medications = medicationMaps.map((map) {
      return MedicationObj.fromDbMap(map);
    }).toList();
    setState(() {
      this.medications = medications;
    });
  }

  refreshNotifications() async {
    final List<Map<String, dynamic>> scheduleRecords = await widget.helper.db.rawQuery(
      'SELECT * FROM schedule INNER JOIN medication ON medication.id = schedule.medication_id'
    );

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
