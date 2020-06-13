import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../obj/DateSchedulesObj.dart';
import '../obj/CheckInObj.dart';

import '../helper/Helper.dart';

import './CheckInUtils.dart';
import '../utils/DateTimeUtils.dart';

class CheckIn extends StatefulWidget {
  final Helper helper;

  CheckIn({Key key, this.helper}) : super(key: key);

  @override
  _CheckInState createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  DateTime checkInDate;
  List<DateSchedulesObj> dateSchedules;
  DateSchedulesObj selectedSchedule;

  editCheckInDate(BuildContext context) async {
    DateTime newCheckInDate = await showDatePicker(
      context: context,
      initialDate: checkInDate,
      firstDate: getUtcDateStartFromLocalDate(DateTime.fromMillisecondsSinceEpoch(0)),
      lastDate: getUtcDateStartFromLocalDate(DateTime.now()),
    );

    if (newCheckInDate != null) {
      newCheckInDate = getUtcDateStartFromLocalDate(newCheckInDate);

      getDateSchedules(newCheckInDate);
    }
  }

  getDateSchedules(DateTime date) async {
    List<DateSchedulesObj> dateSchedules = await widget.helper.medicationDbHelper.getDateSchedules(date);
    List<CheckInObj> dateCheckIns = await widget.helper.checkInDbHelper.getDateCheckIns(date);
    dateSchedules = getUnCheckedInSchedules(dateSchedules, dateCheckIns);

    setState(() {
      this.checkInDate = date;
      this.dateSchedules = dateSchedules;
      if (dateSchedules.length > 0) {
        this.selectedSchedule = dateSchedules[0];
      }
    });
  }

  onSave(BuildContext context) async {
    final bool checkInRes = await widget.helper.checkInDbHelper.checkIn(checkInDate, selectedSchedule.scheduleGroup);

    Navigator.pop(context, checkInRes);
  }

  @override
  void initState() {
    super.initState();

    checkInDate = getUtcDateStartFromLocalDate(DateTime.now());
    dateSchedules = [];

    getDateSchedules(checkInDate);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> selectedScheduleMedicationsComp = [];
    if (selectedSchedule != null) {
      selectedScheduleMedicationsComp = selectedSchedule.medications.map((medication) {
        return Text(medication.name);
      }).toList();
    }

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
            Row(
              children: <Widget>[
                OutlineButton(
                  child: Text(DateFormat.yMMMEd().format(checkInDate)),
                  onPressed: () {
                    editCheckInDate(context);
                  },
                ),
                Spacer(),
                DropdownButton(
                  value: selectedSchedule,
                  onChanged: (DateSchedulesObj selectedSchedule) {
                    setState(() {
                      this.selectedSchedule = selectedSchedule;
                    });
                  },
                  items: dateSchedules.map((dateSchedule) {
                    return DropdownMenuItem<DateSchedulesObj>(
                      value: dateSchedule,
                      child: Text('${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(dateSchedule.scheduleGroup.time, isUtc: true))} (${dateSchedule.medications.length} medications)'),
                    );
                  }).toList(),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text('Medications to take:'),
                ...selectedScheduleMedicationsComp
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
