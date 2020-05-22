class ScheduleMedicationObj {
  final int id;
  final int scheduleGroupId;
  final int medicationId;

  ScheduleMedicationObj(this.id, this.scheduleGroupId, this.medicationId);

  ScheduleMedicationObj.newRecord(int scheduleGroupId, int medicationId) : this(null, scheduleGroupId, medicationId);

  Map<String, dynamic> toDbMap() {
    Map<String, dynamic> dbMap = {
      'schedule_group_id': scheduleGroupId,
      'medication_id': medicationId
    };
    if (id != null) {
      dbMap['id'] = id;
    }
    return dbMap;
  }
}
