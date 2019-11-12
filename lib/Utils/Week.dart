
class Date extends DateTime {

  Date(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : super(year, month, day, hour, minute, second, millisecond, microsecond);

  Date.now() : super.now();

  int getWeekOfYear() {
    DateTime startOfYear = DateTime(year, 1, 1, 0, 0);
    int firstMonday = startOfYear.weekday;
    int daysInFirstWeek = 8 - firstMonday;
    Duration diff = difference(startOfYear);
    int weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
    if (daysInFirstWeek > 3) weeks++;
    return weeks;
  }
}