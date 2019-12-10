import 'dart:convert';

import 'package:flutter/material.dart';

/// Defines all updates
class Updates {
  // ignore: public_member_api_docs
  DateTime timetable;
  // ignore: public_member_api_docs
  DateTime substitutionPlan;
  // ignore: public_member_api_docs
  DateTime cafetoria;
  // ignore: public_member_api_docs
  DateTime calendar;
  // ignore: public_member_api_docs
  DateTime teachers;
  // ignore: public_member_api_docs
  DateTime workgroups;
  // ignore: public_member_api_docs
  DateTime subjects;
  // ignore: public_member_api_docs
  DateTime rooms;
  // ignore: public_member_api_docs
  final int minAppLevel;
  // ignore: public_member_api_docs
  String grade;

  // ignore: public_member_api_docs
  Updates(
      {@required this.timetable,
      @required this.substitutionPlan,
      @required this.cafetoria,
      @required this.calendar,
      @required this.teachers,
      @required this.workgroups,
      @required this.minAppLevel,
      @required this.subjects,
      @required this.rooms,
      @required this.grade});

  /// Creates updates from json map
  factory Updates.fromJson(Map<String, dynamic> json) {
    return Updates(
      timetable: Updates.getDate(json['timetable'] as String),
      substitutionPlan: Updates.getDate(json['substitutionPlan'] as String),
      cafetoria: Updates.getDate(json['cafetoria'] as String),
      calendar: Updates.getDate(json['calendar'] as String),
      teachers: Updates.getDate(json['teachers'] as String),
      workgroups: Updates.getDate(json['workgroups'] as String),
      minAppLevel: json['minAppLevel'] as int,
      subjects: Updates.getDate(json['subjects'] as String),
      rooms: Updates.getDate(json['rooms'] as String),
      grade: json['grade'] as String,
    );
  }

  /// Tries to parse a date string to object
  static DateTime getDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Converts updates to json string
  String toJson() {
    return json.encode(toMap());
  }

  /// Converts updates to json map
  Map<String, dynamic> toMap() {
    return {
      'timetable': timetable.toIso8601String(),
      'substitutionPlan': substitutionPlan.toIso8601String(),
      'cafetoria': cafetoria.toIso8601String(),
      'calendar': calendar.toIso8601String(),
      'teachers': teachers.toIso8601String(),
      'workgroups': workgroups.toIso8601String(),
      'minAppLevel': minAppLevel,
      'subjects': subjects.toIso8601String(),
      'rooms': rooms.toIso8601String(),
      'grade': grade
    };
  }
}
