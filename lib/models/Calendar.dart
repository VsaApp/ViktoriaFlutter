class Calendar {
  static List<CalendarEvent> days;
}

class CalendarEvent {
  final String name;
  final String info;
  final CalendarEventDate start;
  final CalendarEventDate end;

  CalendarEvent({this.name, this.info, this.start, this.end});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      name: json['name'] as String,
      info: json['info'] as String,
      start: CalendarEventDate.fromJson(json['start']),
      end: CalendarEventDate.fromJson(json['end']),
    );
  }
}

class CalendarEventDate {
  final String date;
  final String time;

  CalendarEventDate({this.date, this.time});

  factory CalendarEventDate.fromJson(Map<String, dynamic> json) {
    return CalendarEventDate(
      date: json['date'] as String,
      time: json['time'] as String,
    );
  }
}
