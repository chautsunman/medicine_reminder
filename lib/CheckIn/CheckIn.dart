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

  DateTime lastScheduleChangeTime;

  bool loading;

  editCheckInDate(BuildContext context) async {
    DateTime newCheckInDate = await showDatePicker(
      context: context,
      initialDate: checkInDate,
      firstDate: lastScheduleChangeTime,
      lastDate: getUtcDateStartFromLocalDate(DateTime.now()),
    );

    if (newCheckInDate != null) {
      newCheckInDate = getUtcDateStartFromLocalDate(newCheckInDate);

      updateDateSchedules(newCheckInDate);
    }
  }

  Future<void> updateDateSchedules(DateTime date) async {
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

  init(DateTime checkInDate) async {
    List<dynamic> initRes;

    try {
      initRes = await Future.wait([
        updateDateSchedules(checkInDate),
        widget.helper.medicationDbHelper.getLastScheduleChange()
      ]);
    } catch (e) {
      print('Init error');
      print(e);
      return;
    }

    print('Check in page initialized');

    setState(() {
      this.lastScheduleChangeTime = initRes[1];
      this.loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    loading = true;

    checkInDate = getUtcDateStartFromLocalDate(DateTime.now());
    dateSchedules = [];
    lastScheduleChangeTime = checkInDate;

    init(checkInDate);
  }

  @override
  Widget build(BuildContext context) {
    var content;

    if (!loading) {
      List<Widget> selectedScheduleMedicationsComp = [];
      if (selectedSchedule != null) {
        selectedScheduleMedicationsComp = selectedSchedule.medications.map((medication) {
          return Text(medication.name);
        }).toList();
      }

      content = ListView(
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
      );
    } else {
      content = Center(
        child: CircularProgressIndicator(),
      );
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
        child: content,
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
