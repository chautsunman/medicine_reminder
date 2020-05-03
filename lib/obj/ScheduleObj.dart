class ScheduleObj {
  int id;
  int medicationId;
  int scheduleDay;
  int scheduleTime;
  bool isDeleted = false;

  ScheduleObj({
    this.id,
    this.medicationId,
    this.scheduleDay,
    this.scheduleTime,
    this.isDeleted
  });

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
}
