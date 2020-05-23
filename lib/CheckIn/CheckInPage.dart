import 'package:flutter/material.dart';

import '../helper/Helper.dart';

import '../obj/CheckInObj.dart';
import '../obj/DateScheduleObj.dart';

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

  getCheckIns() async {
    final List<Map<String, dynamic>> checkInMaps = await widget.helper.checkInDbHelper.getCheckIn();
    final List<CheckInObj> checkIns = checkInMaps.map((map) {
      return CheckInObj.fromDbMap(map);
    }).toList();
    setState(() {
      this.checkIns = checkIns;
    });
  }

  getNextSchedule() async {
    final DateScheduleObj nextSchedule = await widget.helper.medicationDbHelper.getNextSchedule();
    setState(() {
      this.nextSchedule = nextSchedule;
    });
  }

  @override
  void initState() {
    super.initState();

    checkIns = [];

    getCheckIns();
    getNextSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final int numberOfListItems = (nextSchedule != null) ? checkIns.length + 1 : checkIns.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Ins'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: numberOfListItems,
          itemBuilder: (context, idx) {
            if (nextSchedule != null && idx == 0) {
              return Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.check),
                      title: Text('Next Time To Take Medicine at ${nextSchedule.date}'),
                      subtitle: Text('${nextSchedule.medicationsCount} medications in total.'),
                    ),
                  ],
                ),
              );
            }

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
