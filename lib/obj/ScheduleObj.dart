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
    return parseDay(scheduleDay);
  }

  setDays(List<bool> days) {
    scheduleDay = calculateDay(days);
  }

  DateTime getTime() {
    return parseTime(scheduleTime);
  }

  setTime(DateTime time) {
    scheduleTime = calculateTime(time);
  }

  ScheduleKey getScheduleKey() {
    return ScheduleKey(scheduleDay, scheduleTime);
  }
}

class ScheduleKey {
  final int day;
  final int time;

  ScheduleKey(this.day, this.time);

  bool valid() {
    return day != null && time != null;
  }
}

List<bool> parseDay(int days) {
  List<bool> parsedDays = List.generate(7, (i) {return false;});
  int dayTemp = (days != null) ? days : 0;
  for (int i = 6; i >= 0; i--) {
    if (dayTemp >= pow(2, i)) {
      parsedDays[i] = true;
      dayTemp -= pow(2, i);
    }
  }
  return parsedDays;
}

int calculateDay(List<bool> days) {
  int dayTemp = 0;
  for (int i = 0; i < days.length; i++) {
    if (days[i]) {
      dayTemp += pow(2, i);
    }
  }
  return dayTemp;
}

DateTime parseTime(int time) {
  if (time != null) {
    return DateTime.fromMillisecondsSinceEpoch(time, isUtc: true);
  }
  return null;
}

int calculateTime(DateTime time) {
  return time.millisecondsSinceEpoch;
}
