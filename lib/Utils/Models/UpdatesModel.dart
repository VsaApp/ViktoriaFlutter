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
