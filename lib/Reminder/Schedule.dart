import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../obj/ScheduleObj.dart';

class Schedule extends StatelessWidget {
  final ScheduleObj schedule;
  final ValueChanged<ScheduleObj> onScheduleChanged;

  Schedule({
    Key key,
    @required this.schedule,
    @required this.onScheduleChanged
  }) : super(key: key);

  onDayClick(day) {
    final ScheduleObj newSchedule = ScheduleObj.copy(schedule);
    newSchedule.days[day] = !schedule.days[day];
    onScheduleChanged(newSchedule);
  }

  onPickTime(context) async {
    final DateTime scheduleTimeDateTime = schedule.time;
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: (scheduleTimeDateTime != null) ? TimeOfDay.fromDateTime(scheduleTimeDateTime) : TimeOfDay.now(),
      context: context,
    );
    final ScheduleObj newSchedule = ScheduleObj.copy(schedule);
    DateTime newTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    newTime = newTime.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute));
    newSchedule.time = newTime;
    onScheduleChanged(newSchedule);
  }

  @override
  Widget build(BuildContext context) {
    final List<bool> parsedDays = schedule.days;
    final DateTime timeDateTime = schedule.time;
    final TimeOfDay timeTimeOfDay = (timeDateTime != null) ? TimeOfDay.fromDateTime(timeDateTime) : null;
    final String timeStr = (timeTimeOfDay != null) ? timeTimeOfDay.format(context) : '';

    return Container(
      child: Column(
        children: <Widget>[
          ButtonBar(
            children: List.generate(7, (idx) {
              return OutlineButton(
                child: Text('$idx ${parsedDays[idx]}'),
                onPressed: () {
                  onDayClick(idx);
                },
              );
            }),
          ),
          OutlineButton(
            child: Text('Time: $timeStr'),
            onPressed: () {
              onPickTime(context);
            },
          ),
        ],
      ),
    );
  }
}
