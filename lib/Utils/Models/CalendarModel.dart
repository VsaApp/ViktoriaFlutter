// Describes a list of calendar events...
import 'package:flutter/material.dart';

class Calendar {
  final List<int> years;
  final List<CalendarEvent> events;

  Calendar({@required this.years, @required this.events});

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
        years: json['years'].cast<int>().toList(),
        events: json['data']
            .map((json) => CalendarEvent.fromJson(json))
            .cast<CalendarEvent>()
            .toList());
  }
}

// Describes a calendar event...
class CalendarEvent {
  String name;
  String info;
  DateTime start;
  DateTime end;

  CalendarEvent(
      {String name, String info, DateTime start, DateTime end, bool free}) {
    this.name = name;
    this.info = info;
    this.start = start != null ? start : end;
    this.end = end != null ? end : start;
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      name: json['name'] as String,
      info: json['info'] as String,
      start: json['start'] != null ? DateTime.parse(json['start']).toLocal() : null,
      end: json['end'] != null ? DateTime.parse(json['end']).toLocal() : null,
    );
  }
}
