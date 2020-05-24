DateTime getSameUtcTimeFromLocalTime(DateTime localTime) {
  return DateTime.utc(
    localTime.year,
    localTime.month,
    localTime.day,
    localTime.hour,
    localTime.minute,
    localTime.second,
    localTime.millisecond
  );
}

DateTime getSameUtcTimeOfNow() {
  return getSameUtcTimeFromLocalTime(DateTime.now());
}
