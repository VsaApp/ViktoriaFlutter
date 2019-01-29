import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../UnitPlan/UnitPlanModel.dart';

// Describes the replacement plan
class ReplacementPlan {
  static List<ReplacementPlanDay> days;
}

// Describes a day of the replacement plan...
class ReplacementPlanDay {
  final String date;
  final String time;
  final String update;
  final String weekday;
  final List<Change> myChanges;
  final List<Change> undefinedChanges;
  final List<Change> otherChanges;
  final List<UnparsedChange> unparsed;

  ReplacementPlanDay({
    @required this.date,
    @required this.time,
    @required this.update,
    @required this.weekday,
    @required this.myChanges,
    @required this.undefinedChanges,
    @required this.otherChanges,
    @required this.unparsed,
  });

  // Set the category colors of the changes...
  void setColors() {
    myChanges.forEach((change) => change.setColor());
    undefinedChanges.forEach((change) => change.setColor());
    otherChanges.forEach((change) => change.setColor());
  }
}

// Desrcibes a change which could not be parsed...
class UnparsedChange {
  final int unit;
  final List<dynamic> original;
  final List<dynamic> change;

  UnparsedChange({
    @required this.unit,
    @required this.original,
    @required this.change,
  });

  factory UnparsedChange.fromJson(Map<String, dynamic> json) {
    return UnparsedChange(
        unit: int.parse(json['unit'] as String) - 1,
        original: json['original'].map((line) => line.toString()).toList(),
        change: json['change'].map((line) => line.toString()).toList());
  }
}

// Describes a change of a replacement plan day...
class Change {
  final int unit;
  final String lesson;
  final String course;
  String room;
  String teacher;
  final Changed changed;
  bool sure;
  Color color;

  Change({
    @required this.unit,
    @required this.lesson,
    @required this.course,
    @required this.room,
    @required this.teacher,
    @required this.changed,
    @required this.sure,
  });

  factory Change.fromJson(Map<String, dynamic> json) {
    return Change(
      unit: json['unit'] as int,
      lesson: json['subject'] as String,
      course: json['course'] as String,
      room: json['room'] as String,
      teacher: json['participant'] as String,
      changed: Changed.fromJson(json['change']),
      sure: json['sure'] as bool,
    );
  }

  // Set color of this change category...
  void setColor() {
    if (changed.info.toLowerCase().contains('klausur'))
      color = Colors.red;
    else if (changed.info.toLowerCase().contains('freistunde'))
      color = null;
    else
      color = Colors.orange;
  }
}

// Describes a changed of a replacement plan change...
class Changed {
  final String info;
  final String teacher;
  final String room;
  final String subject;

  Changed({
    @required this.info,
    @required this.teacher,
    @required this.room,
    @required this.subject,
  });

  factory Changed.fromJson(Map<String, dynamic> json) {
    return Changed(
        info: json['info'] as String,
        teacher: json['teacher'] as String,
        room: json['room'] as String,
        subject: json['subject'] as String);
  }
}

// Returns the selected subject index...
int getSelectedSubject(SharedPreferences sharedPreferences,
    UnitPlanSubject subject, int day, int unit) {
  // If the subject block is set, get index for block, else get index for day + unit...
  return sharedPreferences.getInt(Keys.unitPlan(
      sharedPreferences.getString(Keys.grade),
      block: subject.block,
      day: day,
      unit: unit));
}
