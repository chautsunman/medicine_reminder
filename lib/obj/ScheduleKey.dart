import 'package:equatable/equatable.dart';

class ScheduleKey extends Equatable {
  final int day;
  final int time;

  ScheduleKey(
    this.day,
    this.time
  );

  bool valid() {
    return day != null && time != null;
  }

  DateTime getTime() {
    if (time != null) {
      return DateTime.fromMillisecondsSinceEpoch(time, isUtc: true);
    }
    return null;
  }

  @override
  List<Object> get props => [day, time];
}
