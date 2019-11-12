import 'dart:convert';

import 'package:flutter/material.dart';

class Updates {
  DateTime timetable;
  DateTime substitutionPlan;
  DateTime cafetoria;
  DateTime calendar;
  DateTime teachers;
  DateTime workgroups;
  DateTime subjects;
  DateTime rooms;
  final int minAppLevel;
  String grade;

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

  factory Updates.fromJson(Map<String, dynamic> json) {
    return Updates(
      timetable: DateTime.parse(json['timetable'] as String),
      substitutionPlan: DateTime.parse(json['substitutionPlan'] as String),
      cafetoria: DateTime.parse(json['cafetoria'] as String),
      calendar: DateTime.parse(json['calendar'] as String),
      teachers: DateTime.parse(json['teachers'] as String),
      workgroups: DateTime.parse(json['workgroups'] as String),
      minAppLevel: json['minAppLevel'] as int,
      subjects: DateTime.parse(json['subjects'] as String),
      rooms: DateTime.parse(json['rooms'] as String),
      grade: json['grade'] as String,
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

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
