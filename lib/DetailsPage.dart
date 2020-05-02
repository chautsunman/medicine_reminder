import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';

import 'Medication.dart';

class DetailsPage extends StatefulWidget {
  final Medication medication;

  final Database db;
  final String photoPath;

  DetailsPage({Key key, this.medication, this.db, this.photoPath}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final nameController = TextEditingController();
  File imgFile;

  onSaveBtnPressed(context) async {
    print('onSaveBtnPressed');

    final Medication medication = Medication(
      name: nameController.text
    );

    if (imgFile != null) {
      final photoFileName = '${nameController.text}_${DateTime.now().millisecondsSinceEpoch}';
      await imgFile.copy('${widget.photoPath}/$photoFileName');
      medication.photoFileName = photoFileName;
      print('Photo saved.');
    }

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

  takePhoto() async {
    final imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      this.imgFile = imgFile;
    });
    print('Photo taken.');
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
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
