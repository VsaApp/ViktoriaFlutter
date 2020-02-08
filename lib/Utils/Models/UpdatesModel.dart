import 'dart:convert';

import 'package:flutter/material.dart';

/// Defines all updates
class Updates {
  // ignore: public_member_api_docs
  String timetable;
  // ignore: public_member_api_docs
  String substitutionPlan;
  // ignore: public_member_api_docs
  String cafetoria;
  // ignore: public_member_api_docs
  String calendar;
  // ignore: public_member_api_docs
  String workgroups;
  // ignore: public_member_api_docs
  String subjects;
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
      @required this.workgroups,
      @required this.minAppLevel,
      @required this.subjects,
      @required this.grade});

  /// Creates updates from json map
  factory Updates.fromJson(Map<String, dynamic> json) {
    return Updates(
      timetable: json['timetable'] as String,
      substitutionPlan: json['substitutionPlan'] as String,
      cafetoria: json['cafetoria'] as String,
      calendar: json['calendar'] as String,
      workgroups: json['workgroups'] as String,
      minAppLevel: json['minAppLevel'] as int,
      subjects: json['subjects'] as String,
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
      'timetable': timetable,
      'substitutionPlan': substitutionPlan,
      'cafetoria': cafetoria,
      'calendar': calendar,
      'workgroups': workgroups,
      'minAppLevel': minAppLevel,
      'subjects': subjects,
      'grade': grade
    };
  }
}
