import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';

// Describes the whole unit plan...
class UnitPlan {
  static List<UnitPlanDay> days;

  // Set all default selections...
  static void setAllSelections(SharedPreferences sharedPreferences) {
    days.forEach(
        (day) => day.setSelections(days.indexOf(day), sharedPreferences));
  }
}

// Describes a day of the unit plan...
class UnitPlanDay {
  final String name;
  final List<dynamic> lessons;
  final String replacementPlanForDate;
  final String replacementPlanForWeekday;
  final String replacementPlanUpdatedDate;
  final String replacementPlanUpdatedTime;

  UnitPlanDay({
    @required this.name,
    @required this.lessons,
    @required this.replacementPlanForDate,
    @required this.replacementPlanForWeekday,
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
      replacementPlanUpdatedDate:
          json['replacementplan']['updated']['date'] as String,
      replacementPlanUpdatedTime:
          json['replacementplan']['updated']['time'] as String,
    );
  }

  int getUserLesseonsCount(
      SharedPreferences sharedPreferences, String freeLesson) {
    for (int i = lessons.length - 1; i >= 0; i--) {
      UnitPlanLesson lesson = lessons[i];
      int selected = sharedPreferences.getInt(Keys.unitPlan(
          sharedPreferences.getString(Keys.grade),
          block: lesson.subjects[0].block,
          day: UnitPlan.days.indexOf(this),
          unit: lessons.indexOf(lesson)));
      // If nothing  or a subject (not lunchtime and free lesson) selected return the index...
      if ((selected == null ||
              lesson.subjects[selected].lesson != freeLesson) &&
          i != 5) {
        return i + 1;
      }
    }
    return 0;
  }

  // Set the default selections...
  void setSelections(int day, SharedPreferences sharedPreferences) {
    for (int i = 0; i < lessons.length; i++) {
      lessons[i].setSelection(day, i, sharedPreferences);
    }
  }

  ReplacementPlanDay getReplacementPlanDay(
      SharedPreferences sharedPreferences) {
    String grade = sharedPreferences.getString(Keys.grade);
    List<Change> myChanges = [];
    List<Change> undefinedChanges = [];
    List<Change> otherChanges = [];
    lessons.forEach((lesson) {
      lesson.subjects.forEach((subject) {
        int weekday = [
          'Montag',
          'Dienstag',
          'Mittwoch',
          'Donnerstag',
          'Freitag'
        ].indexOf(name);
        int unit = lessons.indexOf(lesson);
        int i = lesson.subjects.indexOf(subject);
        int s = sharedPreferences.getInt(Keys.unitPlan(
              grade,
              block: subject.block,
              day: weekday,
              unit: unit,
            )) ??
            0;
        subject.changes.forEach((change) {
          (i == s ? (change.sure ? myChanges : undefinedChanges) : otherChanges)
              .add(change);
        });
      });
    });
    return ReplacementPlanDay(
      date: replacementPlanForDate,
      time: replacementPlanUpdatedTime,
      weekday: replacementPlanForWeekday,
      update: replacementPlanUpdatedDate,
      unparsed: [],
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
  void setSelection(int day, int unit, SharedPreferences sharedPreferences) {
    String prefKey = Keys.unitPlan(sharedPreferences.getString(Keys.grade),
        block: subjects[0].block, day: day, unit: unit);
    if (subjects.length == 1 && sharedPreferences.getInt(prefKey) == null) {
      sharedPreferences.setInt(prefKey, 0);
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
  final List<Change> changes;
  final int unsures;

  UnitPlanSubject({
    @required this.teacher,
    @required this.lesson,
    @required this.room,
    @required this.block,
    @required this.course,
    @required this.changes,
    @required this.unsures,
  });

  factory UnitPlanSubject.fromJson(Map<String, dynamic> json) {
    List<Change> changes =
        json['changes'].map((i) => Change.fromJson(i)).toList().cast<Change>();
    return UnitPlanSubject(
      teacher: json['participant'] as String,
      lesson: json['subject'] as String,
      room: json['room'] as String,
      block: json['block'] as String,
      course: json['course'] as String,
      changes: changes,
      unsures: changes.where((change) => !change.sure).length,
    );
  }
}
