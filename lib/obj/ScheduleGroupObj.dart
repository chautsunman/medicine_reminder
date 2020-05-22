class ScheduleGroup {
  final int id;
  final int day;
  final int time;
  final bool active;

  ScheduleGroup(this.id, this.day, this.time, this.active);

  ScheduleGroup.newGroup(int id, int day, int time) : this(id, day, time, true);

  Map<String, dynamic> toDbMap() {
    Map<String, dynamic> dbMap = {
      'schedule_day': day,
      'schedule_time': time
    };
    if (id != null) {
      dbMap['id'] = id;
    }
    return dbMap;
  }
}
