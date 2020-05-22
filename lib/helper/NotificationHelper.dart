import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../obj/ScheduleKey.dart';

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

  addNotifications(Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules) async {
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
        final DateTime timeDateTime = scheduleKey.getTime();
        final Time time = Time(timeDateTime.hour, timeDateTime.minute, timeDateTime.second);

        addNotificationFutures.add(notification.showWeeklyAtDayAndTime(
          notificationIdx,
          'Time to take medication.',
          '${medications.length} medications at ${DateFormat.Hm().format(timeDateTime)}.',
          dayMap[scheduleKey.day],
          time,
          platformChannelSpecifics
        ));
        notificationIdx++;
        print('Added notification at day ${scheduleKey.day} ${DateFormat.Hm().format(timeDateTime)} to take ${medications.length} medications.');
      }
    });

    print('Added $notificationIdx total notifications.');

    return Future.wait(addNotificationFutures);
  }
}

Map<ScheduleKey, List<Map<String, dynamic>>> groupSchedules(List<Map<String, dynamic>> schedulesDbMap) {
  Map<ScheduleKey, List<Map<String, dynamic>>> groupedSchedules = {};
  schedulesDbMap.forEach((scheduleDbMap) {
    final ScheduleKey scheduleKey = ScheduleKey(scheduleDbMap['schedule_day'], scheduleDbMap['schedule_time']);
    if (!groupedSchedules.containsKey(scheduleKey)) {
      groupedSchedules[scheduleKey] = [];
    }
    groupedSchedules[scheduleKey].add(scheduleDbMap);
  });
  return groupedSchedules;
}
