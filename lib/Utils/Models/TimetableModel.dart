import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Week.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

/// Describes the whole timetable...
class Timetable {
  /// All timetable days
  List<TimetableDay> days;

  /// The updated day of the timetable
  DateTime date;

  /// The grade of the timetable
  String grade;

  // ignore: public_member_api_docs
  Timetable({@required this.days, @required this.date, @required this.grade});

  /// Set all default selections...
  void setAllSelections() {
    for (int i = 0; i < days.length; i++) {
      days[i].setSelections(days.indexOf(days[i]));
    }
  }

  /// Creates a timetable for json map
  factory Timetable.fromJSON(Map<String, dynamic> json) {
    return Timetable(
      grade: json['grade'] as String,
      date: DateTime.parse(json['date'] as String).toLocal(),
      days: json['data']['days']
          .map((json) => TimetableDay.fromJson(json))
          .cast<TimetableDay>()
          .toList(),
    );
  }

  /// Resets all selection in the timetable
  void resetAllSelections() {
    days.forEach((d) => d.units.forEach((u) {
          u.substitutions = [];
          u.subjects.forEach((s) => s.substitutions = []);
        }));
  }

  /// Returns all timetable subjects
  List<TimetableSubject> getAllSubjects() {
    return days
        .map((d) => d.units.map((u) => u.subjects).toList())
        .toList()
        .reduce((i1, i2) => List.from(i1)..addAll(i2))
        .reduce((i1, i2) => List.from(i1)..addAll(i2));
  }

  /// return all selected subjects
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

  /// Returns all subjects with the given [courseID]
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
  /// The weekday (0 to 4)
  final int day;

  /// The list of all timetable units on this day
  final List<TimetableUnit> units;

  /// Which week should be shown in the view
  int showWeek;

  // ignore: public_member_api_docs
  TimetableDay({@required this.day, @required this.units}) {
    int week = Date.now().getWeekOfYear();
    if (DateTime.now().day > 5) {
      week++;
    }
    showWeek = week % 2;
  }

  /// Creates a timetable day from json map
  factory TimetableDay.fromJson(Map<String, dynamic> json) {
    return TimetableDay(
      day: json['day'] as int,
      units: json['units']
          .map((i) => TimetableUnit.fromJson(i, json['day'] as int))
          .cast<TimetableUnit>()
          .toList(),
    );
  }

  /// Returns the lessons on this day for the user
  ///
  /// Without free lesson in the end
  int getUserLessonsCount(String freeLesson) {
    for (int i = units.length - 1; i >= 0; i--) {
      final TimetableUnit unit = units[i];
      final TimetableSubject selected = getSelectedSubject(
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

/// Describes a Lesson of a timetable day...
class TimetableUnit {
  /// The unit number (starts with 0)
  final int unit;

  /// All subject in this unit
  final List<TimetableSubject> subjects;

  /// The day index (0 to 4)
  final int day;

  /// All substitution for this unit
  ///
  /// Here will be only the exams. The other substitutions will be directly in the subject
  List<Substitution> substitutions = [];

  // ignore: public_member_api_docs
  TimetableUnit({
    @required this.unit,
    @required this.subjects,
    @required this.day,
  });

  /// Creates a timetable unit from json map
  factory TimetableUnit.fromJson(Map<String, dynamic> json, int day) {
    return TimetableUnit(
        unit: json['unit'] as int,
        subjects: json['subjects']
            .map((i) => TimetableSubject.fromJson(i, day))
            .cast<TimetableSubject>()
            .toList(),
        day: day);
  }

  /// Set the default selection...
  void setSelection(int day, int unit) {
    if (subjects.length == 1) {
      setSelectedSubject(subjects[0], defaultSelection: true);
    }
  }

  /// Return the selected subject
  TimetableSubject getSelected() {
    return getSelectedSubject(subjects);
  }
}

/// Describes a subject of a timetable unit...
class TimetableSubject {
  /// The unit index (starts with 0)
  final int unit;

  /// The uniq subject identifier
  final String id;

  /// The subject name identifier
  final String subjectID;

  /// The teacher name identifier
  final String teacherID;

  /// The room name identifier
  final String roomID;

  /// The uniq course identifier
  final String courseID;

  /// The block of the subject
  final String block;

  /// The day index of the subject (0 to 4)
  final int day;

  /// All substitution for this subject
  List<Substitution> substitutions = [];

  // ignore: public_member_api_docs
  TimetableSubject({
    @required this.unit,
    @required this.id,
    @required this.teacherID,
    @required this.subjectID,
    @required this.roomID,
    @required this.courseID,
    @required this.block,
    @required this.day,
  });

  /// Returns all changes with this subject id
  List<Substitution> getSubstitutions() {
    return [
      ...?substitutions,
      ...?Data.timetable.days[day].units[unit].substitutions
    ];
  }

  /// Check if the exams is already set
  bool get examIsSet => Storage.getBool(Keys.exams(subjectID)) != null;

  /// Get writing exams
  bool get writeExams => Storage.getBool(Keys.exams(subjectID)) ?? true;

  /// Set writing exams
  set writeExams(bool write) {
    Storage.setBool(Keys.exams(subjectID), write);
    Storage.setString(
        Keys.examTimestamp(subjectID), DateTime.now().toIso8601String());
  }

  /// Creates a subject from json map
  factory TimetableSubject.fromJson(Map<String, dynamic> json, int day) {
    return TimetableSubject(
      unit: json['unit'] as int,
      id: json['id'] as String,
      teacherID: json['teacherID'] as String,
      subjectID: json['subjectID'] as String,
      roomID: json['roomID'] as String,
      courseID: json['courseID'] as String,
      block: json['block'] as String,
      day: day,
    );
  }
}
