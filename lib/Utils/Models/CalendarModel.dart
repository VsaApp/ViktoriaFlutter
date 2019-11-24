// Describes a list of calendar events...
import 'package:flutter/material.dart';

/// All school events
class Calendar {
  /// The years of the event
  final List<int> years;

  /// All events
  final List<CalendarEvent> events;

  // ignore: public_member_api_docs
  Calendar({@required this.years, @required this.events});

  /// Cerates the calendar from json map
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
        years: json['years'].cast<int>().toList(),
        events: json['data']
            .map((json) => CalendarEvent.fromJson(json))
            .cast<CalendarEvent>()
            .toList());
  }
}

/// Describes a calendar event...
class CalendarEvent {
  // ignore: public_member_api_docs
  String name;
  // ignore: public_member_api_docs
  String info;
  // ignore: public_member_api_docs
  DateTime start;
  // ignore: public_member_api_docs
  DateTime end;

  // ignore: public_member_api_docs
  CalendarEvent(
      {this.name, this.info, DateTime start, DateTime end}) {
    this.start = start ?? end;
    this.end = end ?? start;
  }

  /// Creates calendar event from json map
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      name: json['name'] as String,
      info: json['info'] as String,
      start: json['start'] != null
          ? DateTime.parse(json['start']).toLocal()
          : null,
      end: json['end'] != null ? DateTime.parse(json['end']).toLocal() : null,
    );
  }
}
