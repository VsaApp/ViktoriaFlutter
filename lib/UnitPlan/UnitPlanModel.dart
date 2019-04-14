import 'package:flutter/material.dart';

import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../Selection.dart';

// Describes the whole unit plan...
class UnitPlan {
  static List<UnitPlanDay> days;

  // Set all default selections...
  static void setAllSelections() {
    for (int i = 0; i < days.length; i++) {
      days[i].setSelections(days.indexOf(days[i]));
    }
  }
}

// Describes a day of the unit plan...
class UnitPlanDay {
  final String name;
  final List<dynamic> lessons;
  final String replacementPlanForDate;
  final String replacementPlanForWeekday;
  final String replacementPlanForWeektype;
  final String replacementPlanUpdatedDate;
  final String replacementPlanUpdatedTime;
  String showWeek = 'A';

  UnitPlanDay({
    @required this.name,
    @required this.lessons,
    @required this.replacementPlanForDate,
    @required this.replacementPlanForWeekday,
    @required this.replacementPlanForWeektype,
    @required this.replacementPlanUpdatedDate,
    @required this.replacementPlanUpdatedTime,
  });

  factory UnitPlanDay.fromJson(Map<String, dynamic> json) {
    return UnitPlanDay(
      name: json['weekday'] as String,
      lessons: json['lessons']
          .values
          .toList()
          .map((i) => UnitPlanLesson.fromJson(i))
          .toList(),
      replacementPlanForDate: json['replacementplan']['for']['date'] as String,
      replacementPlanForWeekday:
      json['replacementplan']['for']['weekday'] as String,
      replacementPlanForWeektype:
      json['replacementplan']['for']['weektype'] as String,
      replacementPlanUpdatedDate:
          json['replacementplan']['updated']['date'] as String,
      replacementPlanUpdatedTime:
          json['replacementplan']['updated']['time'] as String,
    );
  }

  int getUserLesseonsCount(String freeLesson) {
    for (int i = lessons.length - 1; i >= 0; i--) {
      UnitPlanLesson lesson = lessons[i];
      UnitPlanSubject selected = getSelectedSubject(
          lesson.subjects, UnitPlan.days.indexOf(this), lessons.indexOf(lesson),
          week: replacementPlanForWeektype);

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

  ReplacementPlanDay getReplacementPlanDay() {
    List<Change> unparsedChanges = [];
    List<Change> myChanges = [];
    List<Change> undefinedChanges = [];
    List<Change> otherChanges = [];
    int weekday = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag']
        .indexOf(name);
    lessons.forEach((lesson) {
      int unit = lessons.indexOf(lesson);
      int s = getSelectedIndex(lesson.subjects, weekday, unit,
          week: replacementPlanForWeektype);
      lesson.subjects.forEach((subject) {
        int i = lesson.subjects.indexOf(subject);
        subject.changes.forEach((change) {
          if (change.original != null) {
            unparsedChanges.add(change);
          } else {
            if (i == s) {
              if (change.isExam) {
                int isMy = change.isMyExam(replacementPlanForWeektype);
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
      // Delete all double chanes in the other lists...
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

    return ReplacementPlanDay(
      date: replacementPlanForDate,
      time: replacementPlanUpdatedTime,
      weekday: replacementPlanForWeekday,
      weektype: replacementPlanForWeektype,
      update: replacementPlanUpdatedDate,
      unparsed: unparsedChanges,
      myChanges: myChanges,
      undefinedChanges: undefinedChanges,
      otherChanges: otherChanges,
    );
  }
}

// Describes a Lesson of a unit plan day...
class UnitPlanLesson {
  final List<UnitPlanSubject> subjects;

  UnitPlanLesson({
    @required this.subjects,
  });

  factory UnitPlanLesson.fromJson(List<dynamic> json) {
    return UnitPlanLesson(
      subjects: json.map((i) => UnitPlanSubject.fromJson(i)).toList(),
    );
  }

  // Set the default selection...
  Future setSelection(int day, int unit) async {
    if (subjects.length == 1) {
      setSelectedSubject(subjects[0], day, unit);
    }
  }
}

// Describes a subject of a unit plan lesson...
class UnitPlanSubject {
  final String teacher;
  final String lesson;
  final String room;
  final String block;
  final String course;
  final String week;
  final List<Change> changes;
  final int unsures;

  UnitPlanSubject({
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

  factory UnitPlanSubject.fromJson(Map<String, dynamic> json) {
    List<Change> changes =
        json['changes'].map((i) => Change.fromJson(i)).toList().cast<Change>();
    return UnitPlanSubject(
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
