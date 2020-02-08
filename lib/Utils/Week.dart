
/// Defines a date with the week of year function
class Date extends DateTime {

  // ignore: public_member_api_docs
  Date(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : super(year, month, day, hour, minute, second, millisecond, microsecond);

  /// Get the current date
  Date.now() : super.now();

  /// Get the current week of year
  int getWeekOfYear() {
    final DateTime startOfYear = DateTime(year, 1, 1, 0, 0);
    final int firstMonday = startOfYear.weekday;
    final int daysInFirstWeek = 8 - firstMonday;
    final Duration diff = difference(startOfYear);
    int weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
    if (daysInFirstWeek > 3) {
      weeks++;
    }
    return weeks;
  }
}