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
    if (widget.medication == null || widget.medication.id == null) {
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

  Future _saveSchedule(schedules, batch) async {
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
      await _saveSchedule(schedules, batch);
      batch.commit(noResult: true);
    });
    print('Saved.');

    Navigator.pop(context, true);
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
      schedules.add(ScheduleObj(medicationId: widget.medication.id));
    });
  }

  Future<File> _initEditGetImgFile(medication) async {
    if (medication.photoFileName != null) {
      final imgFile = File('${widget.photoPath}/${medication.photoFileName}');
      final imgFileExists = await imgFile.exists();
      if (imgFileExists) {
        return imgFile;
      }
      return null;
    }
    return null;
  }

  Future<List<ScheduleObj>> _initEditGetSchedules(medication) async {
    final List<Map<String, dynamic>> scheduleMaps = await widget.db.query(
      'schedule',
      where: 'medication_id = ?',
      whereArgs: [medication.id],
    );
    final List<ScheduleObj> schedules = scheduleMaps.map((map) {
      return ScheduleObj.fromDbMap(map);
    }).toList();
    return schedules;
  }

  initEdit() async {
    nameController.text = widget.medication.name;
    final List<dynamic> initRes = await Future.wait([
      _initEditGetImgFile(widget.medication),
      _initEditGetSchedules(widget.medication),
    ]);
    setState(() {
      if (initRes[0] != null) {
        imgFile = initRes[0];
      }
      if (initRes[1] != null) {
        schedules = initRes[1];
      }
    });
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
        child: ListView(
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
            Container(
              margin: EdgeInsets.only(top: 8),
              child: FlatButton(
                child: Text('Add'),
                onPressed: addSchedule,
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
