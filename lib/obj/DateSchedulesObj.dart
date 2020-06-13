import './ScheduleGroupObj.dart';
import './MedicationObj.dart';

class DateSchedulesObj {
  final ScheduleGroupObj scheduleGroup;
  List<MedicationObj> medications;

  DateSchedulesObj(this.scheduleGroup, this.medications);

  DateSchedulesObj.newSchedule(ScheduleGroupObj scheduleGroup) : this(scheduleGroup, []);

  addMedication(MedicationObj medication) {
    medications.add(medication);
  }

  static List<DateSchedulesObj> groupDateSchedulesFromDbMap(List<Map<String, dynamic>> dbMap) {
    Map<int, DateSchedulesObj> groupedSchedulesMap = {};

    dbMap.forEach((recordMap) {
      ScheduleGroupObj scheduleGroup = ScheduleGroupObj.fromDbMap(recordMap, keyPrefix: 'schedule_group_');
      MedicationObj medication = MedicationObj.fromDbMap(recordMap, keyPrefix: 'medication_');
      if (!groupedSchedulesMap.containsKey(scheduleGroup.time)) {
        groupedSchedulesMap[scheduleGroup.time] = DateSchedulesObj.newSchedule(scheduleGroup);
      }
      groupedSchedulesMap[scheduleGroup.time].addMedication(medication);
    });

    List<DateSchedulesObj> groupedSchedules = groupedSchedulesMap.values.toList();

    groupedSchedules.sort((groupedSchedule1, groupedSchedule2) {
      return groupedSchedule1.scheduleGroup.time.compareTo(groupedSchedule2.scheduleGroup.time);
    });

    return groupedSchedules;
  }
}
