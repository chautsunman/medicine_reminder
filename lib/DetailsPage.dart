import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';

import 'Schedule.dart';

import 'obj/MedicationObj.dart';
import 'obj/ScheduleObj.dart';

class DetailsPage extends StatefulWidget {
  final MedicationObj medication;

  final Database db;
  final String photoPath;

  DetailsPage({Key key, this.medication, this.db, this.photoPath}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final nameController = TextEditingController();
  File imgFile;
  List<ScheduleObj> schedules = List<ScheduleObj>();

  Future<String> _savePhoto(MedicationObj medication) async {
    if (imgFile != null) {
      final photoFileName = '${nameController.text}_${DateTime.now().millisecondsSinceEpoch}';
      await imgFile.copy('${widget.photoPath}/$photoFileName');
      medication.photoFileName = photoFileName;
      print('Photo saved.');
      return photoFileName;
    }
    return null;
  }

  Future _saveMedication(MedicationObj medication, batch) async {
    if (widget.medication == null && widget.medication.id != null) {
      await batch.insert('medication', medication.toMap());
    } else {
      medication.id = widget.medication.id;
      await batch.update(
        'medication',
        medication.toMap(),
        where: 'id = ?',
        whereArgs: [medication.id]
      );
    }
  }

  Future _saveSchedule(batch) async {
    schedules.forEach((schedule) {
      if (schedule.id == null) {
        batch.insert('schedule', schedule.toMap());
      } else if (!schedule.isDeleted) {
        batch.update(
          'schedule',
          schedule.toMap(),
          where: 'id = ?',
          whereArgs: [schedule.id]
        );
      } else {
        batch.delete(
          'schedule',
          where: 'id = ?',
          whereArgs: [schedule.id]
        );
      }
    });
  }

  onSaveBtnPressed(context) async {
    print('onSaveBtnPressed');

    final MedicationObj medication = MedicationObj(
      name: nameController.text
    );

    final photoFileName = await _savePhoto(medication);
    medication.photoFileName = photoFileName;
    await widget.db.transaction((txn) async {
      var batch = txn.batch();
      await _saveMedication(medication, batch);
      await _saveSchedule(batch);
      batch.commit(noResult: true);
    });
    print('Saved.');

    Navigator.pop(context);
  }

  takePhoto() async {
    final imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      this.imgFile = imgFile;
    });
    print('Photo taken.');
  }

  void onScheduleChanged(int idx, ScheduleObj schedule) {
    setState(() {
      schedules[idx] = schedule;
    });
  }

  addSchedule() {
    setState(() {
      schedules.add(ScheduleObj());
    });
  }

  initEdit() async {
    nameController.text = widget.medication.name;
    if (widget.medication.photoFileName != null) {
      final imgFile = File('${widget.photoPath}/${widget.medication.photoFileName}');
      final imgFileExists = await imgFile.exists();
      if (imgFileExists) {
        setState(() {
          this.imgFile = imgFile;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.medication != null && widget.medication.id != null) {
      print('Editing medication ${widget.medication.id}.');

      initEdit();
    }
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var imgComp;
    if (imgFile != null) {
      imgComp = GestureDetector(
        onTap: takePhoto,
        child: Image(
          image: Image.file(imgFile).image,
        ),
      );
    } else {
      imgComp = IconButton(
        icon: Icon(Icons.camera),
        onPressed: takePhoto,
      );
    }

    final scheduleComps = List.generate(schedules.length, (idx) => Schedule(
      schedule: schedules[idx],
      onScheduleChanged: (schedule) {
        onScheduleChanged(idx, schedule);
      },
    ));

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
            Container(
              margin: EdgeInsets.only(top: 8),
              child: imgComp,
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: scheduleComps,
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
