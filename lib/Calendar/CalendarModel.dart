// Describes a list of calendar events...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar {
  static List<CalendarEvent> events;
}

// Describes a calendar event...
class CalendarEvent {
  String name;
  String info;
  DateTime start;
  DateTime end;
  bool free;

  CalendarEvent({String name, String info, DateTime start, DateTime end, bool free}) {
    this.name = name;
    this.info = info;
    this.start = start != null ? start : end;
    this.end = end != null ? end : start;
    this.free = free;
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    DateFormat format = DateFormat('dd.MM.yyyy HH:mm');
    return CalendarEvent(
      name: json['name'] as String,
      info: json['info'] as String,
      start: json['start']['date'] != null && json['start']['date'] != ''
          ? format.parse(json['start']['date'] +
          ' ' +
          (json['start']['time'] != '' ? json['start']['time'] : '00:00'))
          : null,
      end: json['end']['date'] != null && json['end']['date'] != ''
          ? format.parse(json['end']['date'] +
          ' ' +
          (json['end']['time'] != '' ? json['end']['time'] : '23:59'))
          : null,
      free: json['free'] as bool
    );
  }
}
