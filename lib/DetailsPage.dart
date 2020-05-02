import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';

import 'Medication.dart';

class DetailsPage extends StatefulWidget {
  final Medication medication;

  final Database db;

  DetailsPage({Key key, this.medication, this.db}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final nameController = TextEditingController();

  onSaveBtnPressed(context) async {
    print('onSaveBtnPressed');

    final Medication medication = Medication(
      name: nameController.text
    );

    if (widget.medication == null && widget.medication.id != null) {
      await widget.db.insert('medication', medication.toMap());

      print('Record inserted.');
    } else {
      medication.id = widget.medication.id;
      await widget.db.update(
        'medication',
        medication.toMap(),
        where: 'id = ?',
        whereArgs: [medication.id]
      );

      print('Record updated.');
    }

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if (widget.medication != null && widget.medication.id != null) {
      print('Editing medication ${widget.medication.id}.');

      nameController.text = widget.medication.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Details'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              onSaveBtnPressed(context);
            }
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
