class ScheduleGroupObj {
  final int id;
  final int day;
  final int time;
  final DateTime activeTime;
  final DateTime nonActiveTime;
  final bool active;

  ScheduleGroupObj(this.id, this.day, this.time, this.activeTime, this.nonActiveTime, this.active);

  ScheduleGroupObj.newGroup(int id, int day, int time, DateTime activeTime) : this(id, day, time, activeTime, null, true);

  ScheduleGroupObj.fromDbMap(Map<String, dynamic> dbMap, {String keyPrefix = ''}) : this(
    (dbMap.containsKey('${keyPrefix}id')) ? dbMap['${keyPrefix}id'] : null,
    (dbMap.containsKey('${keyPrefix}schedule_day')) ? dbMap['${keyPrefix}schedule_day'] : null,
    (dbMap.containsKey('${keyPrefix}schedule_time')) ? dbMap['${keyPrefix}schedule_time'] : null,
    (dbMap.containsKey('${keyPrefix}active_time')) ? dbMap['${keyPrefix}active_time'] : null,
    (dbMap.containsKey('${keyPrefix}non_active_time')) ? dbMap['${keyPrefix}non_active_time'] : null,
    (dbMap.containsKey('${keyPrefix}active')) ? dbMap['${keyPrefix}active'] : null
  );

  Map<String, dynamic> toDbMap() {
    Map<String, dynamic> dbMap = {
      'schedule_day': day,
      'schedule_time': time,
      'active_time': activeTime.millisecondsSinceEpoch,
      'non_active_time': nonActiveTime?.millisecondsSinceEpoch,
      'active': 1
    };
    if (id != null) {
      dbMap['id'] = id;
    }
    return dbMap;
  }
}
