class ScheduleLastCheckInObj {
  final int scheduleDay;
  final int scheduleTime;
  final DateTime activeTime;
  final DateTime lastCheckInTime;

  ScheduleLastCheckInObj(this.scheduleDay, this.scheduleTime, this.activeTime, this.lastCheckInTime);

  ScheduleLastCheckInObj.fromDbMap(Map<String, dynamic> dbMap) : this(
    dbMap['schedule_day'],
    dbMap['schedule_time'],
    DateTime.fromMillisecondsSinceEpoch(dbMap['active_time']),
    (dbMap['last_check_in_time'] != null) ? DateTime.fromMillisecondsSinceEpoch(dbMap['last_check_in_time'], isUtc: true) : null
  );

  bool hasMissedCheckInsUntil(DateTime d) {
    DateTime expLastCheckInTime = d;
    final int weekDay = d.weekday % 7 + 1;
    final int scheduleDayTemp = scheduleDay + 1;
    if (weekDay == scheduleDayTemp) {
      DateTime expTime = DateTime.utc(d.year, d.month, d.day).add(Duration(milliseconds: scheduleTime));
      if (d.isAfter(expTime) || activeTime.isAfter(expTime)) {
        expLastCheckInTime = expTime;
      } else {
        expLastCheckInTime = expTime.subtract(Duration(days: 7));
      }
    } else if (weekDay > scheduleDayTemp) {
      expLastCheckInTime = DateTime.utc(d.year, d.month, d.day)
          .subtract(Duration(days: weekDay - scheduleDayTemp))
          .add(Duration(milliseconds: scheduleTime));
    } else {
      expLastCheckInTime = DateTime.utc(d.year, d.month, d.day)
          .subtract(Duration(days: 7 - (weekDay - scheduleDayTemp)))
          .add(Duration(milliseconds: scheduleTime));
    }
    return expLastCheckInTime.isAfter(lastCheckInTime ?? activeTime);
  }
}
