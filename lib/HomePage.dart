import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';

import 'Medication.dart';

class HomePage extends StatefulWidget {
  final String title;

  final Database db;

  HomePage({Key key, this.title, this.db}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Medication> medications;

  getMedications() async {
    final List<Map<String, dynamic>> medicationMaps = await widget.db.query('medication');
    final List<Medication> medications = List.generate(medicationMaps.length, (idx) {
      return Medication(
        id: medicationMaps[idx]['id'],
        name: medicationMaps[idx]['name'],
        photoFileName: medicationMaps[idx]['photo_file_name']
      );
    });
    setState(() {
      this.medications = medications;
    });
  }

  onAdd() async {
    await Navigator.pushNamed(
      context,
      '/details',
      arguments: null
    );

    getMedications();
  }

  onMedicationTap(idx) async {
    await Navigator.pushNamed(
      context,
      '/details',
      arguments: medications[idx]
    );

    getMedications();
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
