import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../obj/ScheduleGroupObj.dart';
import '../obj/MedicationObj.dart';

final Map<int, Day> dayMap = {
  0: Day.Sunday,
  1: Day.Monday,
  2: Day.Tuesday,
  3: Day.Wednesday,
  4: Day.Thursday,
  5: Day.Friday,
  6: Day.Saturday,
};

class NotificationHelper {
  final FlutterLocalNotificationsPlugin notification;

  NotificationHelper(this.notification);

  clearNotifications() {
    notification.cancelAll();
    print('Cleared all old notifications');
  }

  addNotifications(Map<ScheduleGroupObj, List<MedicationObj>> groupedSchedules) async {
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
    groupedSchedules.forEach((scheduleGroup, medications) {
      final DateTime timeDateTime = DateTime.fromMillisecondsSinceEpoch(scheduleGroup.time, isUtc: true);
      final Time time = Time(timeDateTime.hour, timeDateTime.minute, timeDateTime.second);

      addNotificationFutures.add(notification.showWeeklyAtDayAndTime(
        notificationIdx,
        'Time to take medication.',
        '${medications.length} medications at ${DateFormat.Hm().format(timeDateTime)}.',
        dayMap[scheduleGroup.day],
        time,
        platformChannelSpecifics,
        payload: jsonEncode({
          'type': 'checkin',
          'scheduleGroupId': scheduleGroup.id,
        }),
      ));
      notificationIdx++;
      print('Added notification at day ${scheduleGroup.day} ${DateFormat.Hm().format(timeDateTime)} to take ${medications.length} medications.');
    });

    print('Added $notificationIdx total notifications.');

    return Future.wait(addNotificationFutures);
  }
}

Map<ScheduleGroupObj, List<MedicationObj>> groupSchedules(List<Map<String, dynamic>> schedulesDbMap) {
  Map<ScheduleGroupObj, List<MedicationObj>> groupedSchedules = {};
  schedulesDbMap.forEach((scheduleDbMap) {
    final ScheduleGroupObj scheduleGroup = ScheduleGroupObj.fromDbMap(scheduleDbMap);
    if (!groupedSchedules.containsKey(scheduleGroup)) {
      groupedSchedules[scheduleGroup] = [];
    }
    groupedSchedules[scheduleGroup].add(MedicationObj.fromDbMap(scheduleDbMap));
  });
  return groupedSchedules;
}
