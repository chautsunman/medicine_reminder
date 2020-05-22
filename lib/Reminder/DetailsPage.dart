import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'Schedule.dart';

import '../helper/Helper.dart';

import '../obj/MedicationObj.dart';
import '../obj/ScheduleObj.dart';

class DetailsPage extends StatefulWidget {
  final MedicationObj medication;

  final Helper helper;

  DetailsPage({Key key, @required this.medication, @required this.helper}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final nameController = TextEditingController();
  File imgFile;
  List<ScheduleObj> schedules = List<ScheduleObj>();
  List<ScheduleObj> oldSchedules = List<ScheduleObj>();

  Future<String> _savePhoto(MedicationObj medication) async {
    if (imgFile != null) {
      final photoFileName = '${nameController.text}_${DateTime.now().millisecondsSinceEpoch}';
      await imgFile.copy('${widget.helper.photoPath}/$photoFileName');
      medication.photoFileName = photoFileName;
      print('Photo saved.');
      return photoFileName;
    }
    return null;
  }

  onSaveBtnPressed(context) async {
    print('onSaveBtnPressed');

    final MedicationObj medication = MedicationObj(
      id: widget.medication.id,
      name: nameController.text
    );

    final photoFileName = await _savePhoto(medication);
    medication.photoFileName = photoFileName;
    await widget.helper.medicationDbHelper.saveMedication(medication, schedules, oldSchedules);
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
      schedules.add(ScheduleObj.empty());
    });
  }

  Future<File> _initEditGetImgFile(medication) async {
    if (medication.photoFileName != null) {
      final imgFile = File('${widget.helper.photoPath}/${medication.photoFileName}');
      final imgFileExists = await imgFile.exists();
      if (imgFileExists) {
        return imgFile;
      }
      return null;
    }
    return null;
  }

  Future<List<ScheduleObj>> _initEditGetSchedules(medication) async {
    final List<Map<String, dynamic>> scheduleMaps = await widget.helper.medicationDbHelper.getMedicationSchedules(medication.id);
    final List<ScheduleObj> schedules = scheduleMaps.map((map) {
      final List<String> scheduleDays = map['schedule_days'].split(',');
      List<bool> scheduleDayBools = List.filled(7, false);
      scheduleDays.forEach((dayStr) {
        final int day = int.tryParse(dayStr);
        if (day != null) {
          scheduleDayBools[day] = true;
        }
      });
      return ScheduleObj(scheduleDayBools, DateTime.fromMillisecondsSinceEpoch(map['schedule_time'], isUtc: true));
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
        schedules = List.from(initRes[1]);
        oldSchedules = List.from(initRes[1]);
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
