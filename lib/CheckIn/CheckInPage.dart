import 'package:flutter/material.dart';

import '../helper/Helper.dart';

import '../obj/DateScheduleObj.dart';
import '../obj/ScheduleLastCheckInObj.dart';
import '../obj/CheckInObj.dart';

class CheckInPage extends StatefulWidget {
  final String title;

  final Helper helper;

  CheckInPage({Key key, this.title, this.helper}) : super(key: key);

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<CheckInObj> checkIns;
  DateScheduleObj nextSchedule;
  int missedCheckIns;

  getNextSchedule() async {
    final DateScheduleObj nextSchedule = await widget.helper.medicationDbHelper.getNextSchedule();
    setState(() {
      this.nextSchedule = nextSchedule;
    });
  }

  getMissedCheckIns() async {
    final List<ScheduleLastCheckInObj> lastCheckIns = await widget.helper.checkInDbHelper.getLastCheckIns();
    final DateTime now = DateTime.now();
    int missedCheckIns = lastCheckIns.where((lastCheckIn) => lastCheckIn.hasMissedCheckInsUntil(now)).toList().length;
    setState(() {
      this.missedCheckIns = missedCheckIns;
    });
  }

  getCheckIns() async {
    final List<Map<String, dynamic>> checkInMaps = await widget.helper.checkInDbHelper.getCheckIn();
    final List<CheckInObj> checkIns = checkInMaps.map((map) {
      return CheckInObj.fromDbMap(map);
    }).toList();
    setState(() {
      this.checkIns = checkIns;
    });
  }

  @override
  void initState() {
    super.initState();

    checkIns = [];
    missedCheckIns = 0;

    getNextSchedule();
    getMissedCheckIns();
    getCheckIns();
  }

  @override
  Widget build(BuildContext context) {
    final int numberOfListItems = (nextSchedule != null) ? checkIns.length + 2 : checkIns.length + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Ins'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: numberOfListItems,
          itemBuilder: (context, idx) {
            // next time to take medicine
            if (nextSchedule != null && idx == 0) {
              return Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.alarm),
                      title: Text('Next Time To Take Medicine at ${nextSchedule.date}'),
                      subtitle: Text('${nextSchedule.medicationsCount} medications in total.'),
                    ),
                  ],
                ),
              );
            }

            // missed check ins
            if ((nextSchedule != null && idx == 1) || (nextSchedule == null && idx == 0)) {
              String missedCheckInsText;
              if (missedCheckIns <= 0) {
                missedCheckInsText = 'No missed check ins!';
              } else {
                missedCheckInsText = '$missedCheckIns missed check ins.';
              }

              return Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.check),
                      title: Text(missedCheckInsText),
                    ),
                  ],
                ),
              );
            }

            // check in record
            return ListTile(
              title: Text(checkIns[idx].checkInTime.toString()),
              onTap: null,
            );
          },
        ),
      ),
    );
  }
}
