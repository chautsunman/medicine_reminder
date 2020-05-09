import 'dart:math';

class ScheduleObj {
  int id;
  int medicationId;
  int scheduleDay;
  int scheduleTime;
  bool isDeleted;

  ScheduleObj({
    this.id,
    this.medicationId,
    this.scheduleDay,
    this.scheduleTime,
    this.isDeleted
  });

  ScheduleObj.fromDbMap(Map<String, dynamic> map) : this(
    id: map['id'],
    medicationId: map['medication_id'],
    scheduleDay: map['schedule_day'],
    scheduleTime: map['schedule_time'],
    isDeleted: false,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'medication_id': medicationId,
      'schedule_day': scheduleDay,
      'schedule_time': scheduleTime
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  ScheduleObj.copy(ScheduleObj schedule) : this(
    id: schedule.id,
    medicationId: schedule.medicationId,
    scheduleDay: schedule.scheduleDay,
    scheduleTime: schedule.scheduleTime,
    isDeleted: schedule.isDeleted,
  );

  List<bool> getDays() {
    List<bool> parsedDays = List.generate(7, (i) {return false;});
    int dayTemp = (scheduleDay != null) ? scheduleDay : 0;
    for (int i = 6; i >= 0; i--) {
      if (dayTemp >= pow(2, i)) {
        parsedDays[i] = true;
        dayTemp -= pow(2, i);
      }
    }
    return parsedDays;
  }

  setDays(List<bool> days) {
    int dayTemp = 0;
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        dayTemp += pow(2, i);
      }
    }
    scheduleDay = dayTemp;
  }

  DateTime getTime() {
    if (scheduleTime != null) {
      return DateTime.fromMillisecondsSinceEpoch(scheduleTime, isUtc: true);
    }
    return null;
  }

  setTime(DateTime time) {
    scheduleTime = time.millisecondsSinceEpoch;
  }
}
