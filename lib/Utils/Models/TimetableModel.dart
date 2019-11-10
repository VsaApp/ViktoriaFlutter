import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models/SubstitutionPlanModel.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';

// Describes the whole timetable...
class Timetable {
  static List<TimetableDay> days;

  // Set all default selections...
  static void setAllSelections() {
    for (int i = 0; i < days.length; i++) {
      days[i].setSelections(days.indexOf(days[i]));
    }
  }
}

// Describes a day of the timetable...
class TimetableDay {
  final String name;
  final List<dynamic> lessons;
  final String substitutionPlanForDate;
  final String substitutionPlanForWeekday;
  final String substitutionPlanForWeektype;
  final String substitutionPlanUpdatedDate;
  final String substitutionPlanUpdatedTime;
  String showWeek = 'A';

  TimetableDay({
    @required this.name,
    @required this.lessons,
    @required this.substitutionPlanForDate,
    @required this.substitutionPlanForWeekday,
    @required this.substitutionPlanForWeektype,
    @required this.substitutionPlanUpdatedDate,
    @required this.substitutionPlanUpdatedTime,
  });

  factory TimetableDay.fromJson(Map<String, dynamic> json) {
    return TimetableDay(
      name: json['weekday'] as String,
      lessons: json['lessons']
          .values
          .toList()
          .map((i) => TimetableLesson.fromJson(i))
          .toList(),
      substitutionPlanForDate: json['substitutionPlan']['for']['date'] as String,
      substitutionPlanForWeekday:
      json['substitutionPlan']['for']['weekday'] as String,
      substitutionPlanForWeektype:
      json['substitutionPlan']['for']['weektype'] as String,
      substitutionPlanUpdatedDate:
          json['substitutionPlan']['updated']['date'] as String,
      substitutionPlanUpdatedTime:
          json['substitutionPlan']['updated']['time'] as String,
    );
  }

  int getUserLessonsCount(String freeLesson) {
    for (int i = lessons.length - 1; i >= 0; i--) {
      TimetableLesson lesson = lessons[i];
      TimetableSubject selected = getSelectedSubject(
          lesson.subjects, Timetable.days.indexOf(this), lessons.indexOf(lesson),
          week: substitutionPlanForWeektype);

      // If nothing  or a subject (not lunchtime and free lesson) selected return the index...
      if ((selected == null || selected.lesson != freeLesson) && i != 5) {
        return i + 1;
      }
    }
    return 0;
  }

  // Set the default selections...
  Future setSelections(int day) async {
    for (int i = 0; i < lessons.length; i++) {
      await lessons[i].setSelection(day, i);
    }
  }

  List<Change> getEqualChanges(List<Change> changes, Change change) {
    changes = changes.where((Change c) => c != change).toList();
    return changes.where((Change c) => change.equals(c)).toList();
  }

  SubstitutionPlanDay getSubstitutionPlanDay() {
    List<Change> unparsedChanges = [];
    List<Change> myChanges = [];
    List<Change> undefinedChanges = [];
    List<Change> otherChanges = [];
    int weekday = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag']
        .indexOf(name);
    lessons.forEach((lesson) {
      int unit = lessons.indexOf(lesson);
      int s = getSelectedIndex(lesson.subjects, weekday, unit,
          week: substitutionPlanForWeektype);
      lesson.subjects.forEach((subject) {
        int i = lesson.subjects.indexOf(subject);
        subject.changes.forEach((change) {
          if (change.original != null) {
            unparsedChanges.add(change);
          } else {
            if (i == s) {
              if (change.isExam) {
                int isMy = change.isMyExam(substitutionPlanForWeektype);
                (isMy == 1 && s != null
                        ? myChanges
                        : (isMy == -1 ? undefinedChanges : otherChanges))
                    .add(change);
              } else {
                (change.sure ? myChanges : undefinedChanges).add(change);
              }
            } else {
              otherChanges.add(change);
            }
          }
        });
      });
    });

    for (int i = 0; i < 3; i++) {
      List<Change> listToEdit =
          i == 0 ? myChanges : i == 1 ? undefinedChanges : otherChanges;
      // Delete all double changes in the same list...
      for (int j = 0; j < listToEdit.length; j++) {
        Change change = listToEdit[j];
        List<Change> equalChanges = getEqualChanges(listToEdit, change);
        if (equalChanges.length > 0) {
          listToEdit.removeWhere((Change c) => equalChanges.contains(c));
          j = 0;
          continue;
        }
      }
      // Delete all double changes in the other lists...
      for (int j = 0; j < listToEdit.length; j++) {
        Change change = listToEdit[j];
        // If change is in myChanges, delete in other lists...
        if (i == 0) {
          List<Change> equalChanges = getEqualChanges(otherChanges, change);
          otherChanges.removeWhere((Change c) => equalChanges.contains(c));
          equalChanges = getEqualChanges(undefinedChanges, change);
          undefinedChanges.removeWhere((Change c) => equalChanges.contains(c));
        }
        // If change is in undefinedChanges, delete in otherChanges...
        else if (i == 1) {
          List<Change> equalChanges = getEqualChanges(otherChanges, change);
          otherChanges.removeWhere((Change c) => equalChanges.contains(c));
        }
      }
      if (i == 0)
        myChanges = listToEdit;
      else if (i == 1)
        undefinedChanges = listToEdit;
      else
        otherChanges = listToEdit;
    }

    return SubstitutionPlanDay(
      date: substitutionPlanForDate,
      time: substitutionPlanUpdatedTime,
      weekday: substitutionPlanForWeekday,
      weektype: substitutionPlanForWeektype,
      update: substitutionPlanUpdatedDate,
      unparsed: unparsedChanges,
      myChanges: myChanges,
      undefinedChanges: undefinedChanges,
      otherChanges: otherChanges,
    );
  }
}

// Describes a Lesson of a timetable day...
class TimetableLesson {
  final List<TimetableSubject> subjects;

  TimetableLesson({
    @required this.subjects,
  });

  factory TimetableLesson.fromJson(List<dynamic> json) {
    return TimetableLesson(
      subjects: json.map((i) => TimetableSubject.fromJson(i)).toList(),
    );
  }

  // Set the default selection...
  Future setSelection(int day, int unit) async {
    if (subjects.length == 1) {
      setSelectedSubject(subjects[0], day, unit);
    }
  }
}

// Describes a subject of a timetable lesson...
class TimetableSubject {
  final String teacher;
  final String lesson;
  final String room;
  final String block;
  final String course;
  final String week;
  final List<Change> changes;
  final int unsures;

  TimetableSubject({
    @required this.teacher,
    @required this.lesson,
    @required this.room,
    @required this.block,
    @required this.course,
    @required this.week,
    @required this.changes,
    @required this.unsures,
  });

  List<Change> getChanges(String week) {
    List<Change> changes =
        this.changes.where((Change change) => !change.isExam).toList();
    List<Change> exams =
        this.changes.where((Change change) => change.isExam).toList();
    return changes
      ..addAll(exams.where((Change exam) => exam.isMyExam(week) != 0).toList());
  }

  factory TimetableSubject.fromJson(Map<String, dynamic> json) {
    List<Change> changes =
        json['changes'].map((i) => Change.fromJson(i)).toList().cast<Change>();
    return TimetableSubject(
        teacher: json['participant'] as String,
        lesson: json['subject'] as String,
        room: json['room'] as String,
        block: json['block'] as String,
        course: json['course'] as String,
        week: json['week'] as String,
        changes: changes,
        unsures: changes.where((change) => !change.sure).length);
  }
}
