import 'ScheduleKey.dart';

class ScheduleObj {
  List<bool> days;
  DateTime time;

  ScheduleObj(
    this.days,
    this.time
  );

  ScheduleObj.empty() :
  this(
    List.filled(7, false),
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
  );

  ScheduleObj.copy(ScheduleObj oldSchedule)
  : this(
    List.from(oldSchedule.days),
    DateTime.fromMillisecondsSinceEpoch(oldSchedule.time.millisecondsSinceEpoch, isUtc: true)
  );

  Set<ScheduleKey> getScheduleKeys() {
    Set<ScheduleKey> scheduleKeys = Set<ScheduleKey>();
    for (int dayIdx = 0; dayIdx < days.length; dayIdx++) {
      if (days[dayIdx]) {
        scheduleKeys.add(ScheduleKey(dayIdx, time.millisecondsSinceEpoch));
      }
    }
    return scheduleKeys;
  }
}
