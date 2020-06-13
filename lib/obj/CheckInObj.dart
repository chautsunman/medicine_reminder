class CheckInObj {
  final int id;
  final int scheduleGroupId;
  DateTime medicationTime;
  DateTime checkInTime;

  CheckInObj(this.id, this.scheduleGroupId, this.medicationTime, this.checkInTime);

  CheckInObj.newCheckIn(int scheduleGroupId) : this(null, scheduleGroupId, null, null);

  CheckInObj.fromDbMap(Map<String, dynamic> dbMap) : this(
    dbMap['id'],
    dbMap['schedule_group_id'],
    DateTime.fromMillisecondsSinceEpoch(dbMap['medication_date'], isUtc: true),
    DateTime.fromMillisecondsSinceEpoch(dbMap['check_in_time'], isUtc: true)
  );

  Map<String, dynamic> toDbMap() {
    Map<String, dynamic> dbMap = {
      'schedule_group_id': scheduleGroupId,
      'medications_time': medicationTime.millisecondsSinceEpoch,
      'check_in_time': checkInTime.millisecondsSinceEpoch
    };
    if (id != null) {
      dbMap['id'] = id;
    }
    return dbMap;
  }
}
