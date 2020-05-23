class CheckInObj {
  final int id;
  final int scheduleGroupId;
  final DateTime checkInTime;

  CheckInObj(this.id, this.scheduleGroupId, this.checkInTime);

  CheckInObj.newCheckIn(int scheduleGroupId) : this(null, scheduleGroupId, DateTime.now());

  CheckInObj.fromDbMap(Map<String, dynamic> dbMap) : this(
    dbMap['id'],
    dbMap['schedule_group_id'],
    DateTime.fromMillisecondsSinceEpoch(dbMap['check_in_time'])
  );

  Map<String, dynamic> toDbMap() {
    Map<String, dynamic> dbMap = {
      'schedule_group_id': scheduleGroupId,
      'check_in_time': checkInTime.millisecondsSinceEpoch
    };
    if (id != null) {
      dbMap['id'] = id;
    }
    return dbMap;
  }
}
