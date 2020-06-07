import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../helper/Helper.dart';

import '../utils/DateTimeUtils.dart';

class CheckIn extends StatefulWidget {
  final Helper helper;

  CheckIn({Key key, this.helper}) : super(key: key);

  @override
  _CheckInState createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  DateTime checkInDate;

  editCheckInDate(BuildContext context) async {
    DateTime newCheckInDate = await showDatePicker(
      context: context,
      initialDate: checkInDate,
      firstDate: getUtcDateStartFromLocalDate(DateTime.fromMillisecondsSinceEpoch(0)),
      lastDate: getUtcDateStartFromLocalDate(DateTime.now()),
    );

    if (newCheckInDate != null) {
      this.setState(() {
        this.checkInDate = getUtcDateStartFromLocalDate(newCheckInDate);
      });
    }
  }

  onSave(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    checkInDate = getUtcDateStartFromLocalDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              onSave(context);
            }
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            OutlineButton(
              child: Text(DateFormat.yMMMEd().format(checkInDate)),
              onPressed: () {
                editCheckInDate(context);
              },
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
