import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Week.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

/// Describes the whole timetable...
class Timetable {
  List<TimetableDay> days;
  DateTime date;
  String grade;

  Timetable({@required this.days, @required this.date, @required this.grade});

  /// Set all default selections...
  void setAllSelections() {
    for (int i = 0; i < days.length; i++) {
      days[i].setSelections(days.indexOf(days[i]));
    }
  }

  factory Timetable.fromJSON(Map<String, dynamic> json) {
    return Timetable(
      grade: json['grade'] as String,
      date: DateTime.parse(json['date'] as String),
      days: json['data']['days']
          .map((json) => TimetableDay.fromJson(json))
          .cast<TimetableDay>()
          .toList(),
    );
  }

  List<TimetableSubject> getAllSubjects({bool reset = false}) {
    return days
        .map((d) => d.units.map((u) {
              if (reset) {
                u.substitutions = [];
                u.subjects.forEach((s) => s.substitutions = []);
              }
              return u.subjects;
            }).toList())
        .toList()
        .reduce((i1, i2) => List.from(i1)..addAll(i2))
        .reduce((i1, i2) => List.from(i1)..addAll(i2));
  }

  List<TimetableSubject> getAllSelectedSubjects() {
    return days
        .map((TimetableDay day) {
          return day.units.map((TimetableUnit unit) {
            return unit.getSelected();
          }).toList();
        })
        .toList()
        .reduce((List<TimetableSubject> i1, List<TimetableSubject> i2) =>
            List.from(i1)..addAll(i2))
        .where((subject) => subject != null && subject.unit != 5)
        .toList();
  }

  List<TimetableUnit> getAllSubjectsWithCourseID(String courseID) {
    return days
        .map((TimetableDay day) => day.units
            .where((TimetableUnit unit) => unit.subjects
                .map((subject) => subject.courseID)
                .contains(courseID))
            .toList())
        .toList()
        .reduce((i1, i2) => List.from(i1)..addAll(i2));
  }
}

/// Describes a day of the timetable...
class TimetableDay {
  final int day;
  final List<TimetableUnit> units;
  int showWeek;

  TimetableDay({@required this.day, @required this.units}) {
    int week = Date.now().getWeekOfYear();
    if (DateTime.now().day > 5) week++;
    showWeek = week % 2;
  }

  factory TimetableDay.fromJson(Map<String, dynamic> json) {
    return TimetableDay(
      day: json['day'] as int,
      units: json['units']
          .map((i) => TimetableUnit.fromJson(i, json['day'] as int))
          .cast<TimetableUnit>()
          .toList(),
    );
  }

  int getUserLessonsCount(String freeLesson) {
    for (int i = units.length - 1; i >= 0; i--) {
      TimetableUnit unit = units[i];
      TimetableSubject selected = getSelectedSubject(
        unit.subjects,
        week: showWeek,
      );

      // If nothing  or a subject (not lunchtime and free lesson) selected return the index...
      if ((selected == null || selected.subjectID != freeLesson) && i != 5) {
        return i + 1;
      }
    }
    return 0;
  }

  /// Set the default selections...
  Future setSelections(int day) async {
    for (int i = 0; i < units.length; i++) {
      units[i].setSelection(day, i);
    }
  }

  /// Returns all equals changes
  List<Substitution> getEqualChanges(
      List<Substitution> changes, Substitution change) {
    changes = changes.where((Substitution c) => c != change).toList();
    return changes.where((Substitution c) => change.equals(c)).toList();
  }
}

// Describes a Lesson of a timetable day...
class TimetableUnit {
  final int unit;
  final List<TimetableSubject> subjects;
  final int day;
  List<Substitution> substitutions = [];

  TimetableUnit({
    @required this.unit,
    @required this.subjects,
    @required this.day,
  });

  factory TimetableUnit.fromJson(Map<String, dynamic> json, int day) {
    return TimetableUnit(
        unit: json['unit'] as int,
        subjects: json['subjects']
            .map((i) => TimetableSubject.fromJson(i, day))
            .cast<TimetableSubject>()
            .toList(),
        day: day);
  }

  // Set the default selection...
  void setSelection(int day, int unit) {
    if (subjects.length == 1) {
      setSelectedSubject(subjects[0], defaultSelection: true);
    }
  }

  TimetableSubject getSelected() {
    return getSelectedSubject(subjects);
  }
}

// Describes a subject of a timetable unit...
class TimetableSubject {
  final int unit;
  final String id;
  final String subjectID;
  final String teacherID;
  final String roomID;
  final String courseID;
  final int week;
  final String block;
  final int day;
  List<Substitution> substitutions = [];

  TimetableSubject({
    @required this.unit,
    @required this.id,
    @required this.teacherID,
    @required this.subjectID,
    @required this.roomID,
    @required this.courseID,
    @required this.week,
    @required this.block,
    @required this.day,
  });

  /// Returns all changes with this subject id
  List<Substitution> getSubstitutions() {
    return (substitutions ?? [])
      ..addAll(Data.timetable.days[day].units[unit].substitutions ?? []);
  }

  /// Define exams settings
  bool get examIsSet => Storage.getBool(Keys.exams(courseID)) != null;
  bool get writeExams => Storage.getBool(Keys.exams(courseID)) ?? true;
  set writeExams(bool write) => Storage.setBool(Keys.exams(courseID), write);

  factory TimetableSubject.fromJson(Map<String, dynamic> json, int day) {
    return TimetableSubject(
        unit: json['unit'] as int,
        id: json['id'] as String,
        teacherID: json['teacherID'] as String,
        subjectID: json['subjectID'] as String,
        roomID: json['roomID'] as String,
        courseID: json['courseID'] as String,
        week: json['week'] as int,
        block: json['block'] as String,
        day: day);
  }
}
