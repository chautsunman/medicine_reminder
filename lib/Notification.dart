import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'obj/ScheduleObj.dart';
import 'obj/MedicationObj.dart';

final Map<int, Day> dayMap = {
  0: Day.Sunday,
  1: Day.Monday,
  2: Day.Tuesday,
  3: Day.Wednesday,
  4: Day.Thursday,
  5: Day.Friday,
  6: Day.Saturday,
};

Map<ScheduleKey, List<Map<String, dynamic>>> groupSchedules(List<Map<String, dynamic>> schedulesDbMap) {
  Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules = {};
  schedulesDbMap.forEach((map) {
    ScheduleObj schedule = ScheduleObj.fromDbMap(map);
    MedicationObj medication = MedicationObj.fromDbMap(map);
    final ScheduleKey scheduleKey = schedule.getScheduleKey();
    if (!groupedSchedules.containsKey(scheduleKey)) {
      groupedSchedules[scheduleKey] = [];
    }
    groupedSchedules[scheduleKey].add({
      'schedule': schedule,
      'medication': medication,
    });
  });
  return groupedSchedules;
}

clearNotifications(FlutterLocalNotificationsPlugin notifications) {
  notifications.cancelAll();
}

addNotifications(FlutterLocalNotificationsPlugin notifications, Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules) async {
  List<Future<dynamic>> addNotificationFutures = [];

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'medication',
    'Medication',
    'Medication Reminder',
    importance: Importance.Max,
    priority: Priority.High,
  );
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  int notificationIdx = 0;
  groupedSchedules.forEach((scheduleKey, medications) {
    if (scheduleKey.valid()) {
      final List<bool> days = parseDay(scheduleKey.day);
      final DateTime timeDateTime = parseTime(scheduleKey.time);
      final Time time = Time(timeDateTime.hour, timeDateTime.minute, timeDateTime.second);

      for (int idx = 0; idx < days.length; idx++) {
        if (days[idx]) {
          addNotificationFutures.add(notifications.showWeeklyAtDayAndTime(
            notificationIdx,
            'Time to take medication.',
            '${medications.length} medications at ${DateFormat.Hm().format(timeDateTime)}.',
            dayMap[idx],
            time,
            platformChannelSpecifics
          ));
          notificationIdx++;
        }
      }
    }
  });

  return Future.wait(addNotificationFutures);
}
