import 'package:flutter/material.dart';

import '../helper/Helper.dart';

import '../obj/DateScheduleObj.dart';
import '../obj/ScheduleLastCheckInObj.dart';
import '../obj/CheckInObj.dart';

import '../utils/DateTimeUtils.dart';

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

  Future<DateScheduleObj> getNextSchedule() async {
    try {
      final DateScheduleObj nextSchedule = await widget.helper.medicationDbHelper.getNextSchedule();
      return nextSchedule;
    } catch (e) {
      print('Get next schedule error.');
      print(e);
    }
    return null;
  }

  Future<int> getMissedCheckIns() async {
    try {
      final List<ScheduleLastCheckInObj> lastCheckIns = await widget.helper.checkInDbHelper.getLastCheckIns();
      final DateTime now = getSameUtcTimeOfNow();
      int missedCheckIns = lastCheckIns.where((lastCheckIn) => lastCheckIn.hasMissedCheckInsUntil(now)).toList().length;
      return missedCheckIns;
    } catch (e) {
      print('Get missed check ins error.');
      print(e);
    }
    return null;
  }

  Future<List<CheckInObj>> getCheckIns() async {
    try {
      final List<Map<String, dynamic>> checkInMaps = await widget.helper.checkInDbHelper.getCheckIn();
      final List<CheckInObj> checkIns = checkInMaps.map((map) {
        return CheckInObj.fromDbMap(map);
      }).toList();
      return checkIns;
    } catch (e) {
      print('Get check ins error.');
      print(e);
    }
    return null;
  }

  initPage() async {
    try {
      final initRes = await Future.wait([
        getNextSchedule(),
        getMissedCheckIns(),
        getCheckIns()
      ]);

      setState(() {
        if (initRes[0] != null) {
          this.nextSchedule = initRes[0];
        }
        if (initRes[1] != null) {
          this.missedCheckIns = initRes[1];
        }
        if (initRes[2] != null) {
          this.checkIns = initRes[2];
        }
      });
    } catch (e) {
      print('Init page error.');
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    checkIns = [];
    missedCheckIns = 0;

    initPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Ins'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: checkIns.length + 2,
          itemBuilder: (context, idx) {
            // next time to take medicine
            if (idx == 0) {
              if (nextSchedule == null) {
                return null;
              }

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
            if (idx == 1) {
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
