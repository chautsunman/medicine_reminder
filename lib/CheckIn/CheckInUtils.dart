import '../obj/DateSchedulesObj.dart';
import '../obj/CheckInObj.dart';

List<DateSchedulesObj> getUnCheckedInSchedules(List<DateSchedulesObj> schedules, List<CheckInObj> checkIns) {
  Set<int> checkInScheduleGroupIds = checkIns.map((checkIn) => checkIn.scheduleGroupId).toSet();
  return schedules.where((schedule) => !checkInScheduleGroupIds.contains(schedule.scheduleGroup.id)).toList();
}
