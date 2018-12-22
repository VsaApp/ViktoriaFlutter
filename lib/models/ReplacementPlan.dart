import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Subjects.dart';
import 'UnitPlan.dart';

class ReplacementPlan {
  static List<ReplacementPlanDay> days;

  static void update(SharedPreferences sharedPreferences) {
    UnitPlan.resetChanges();
    days.forEach((day) => day.insertInUnitPlan(sharedPreferences));
  }

  static void updateFilter(UnitPlanDay day, UnitPlanLesson lesson,
      SharedPreferences sharedPreferences) {
    // Need to update the whole unitplan, because of the exams...
    update(sharedPreferences);
  }
}

class ReplacementPlanDay {
  final String date;
  final String time;
  final String update;
  final String weekday;
  final List<dynamic> changes;

  ReplacementPlanDay(
      {this.date, this.time, this.update, this.weekday, this.changes});

  factory ReplacementPlanDay.fromJson(Map<String, dynamic> json) {
    return ReplacementPlanDay(
      date: json['for']['date'] as String,
      time: json['updated']['time'] as String,
      update: json['updated']['date'] as String,
      weekday: json['for']['weekday'] as String,
      changes: json['data']
          .map((i) => Change.fromJson(i, (json['for']['weekday'] as String)))
          .toList(),
    );
  }

  List<dynamic> getMyChanges() {
    return changes.where((change) => change.isMy == 1).toList();
  }

  List<dynamic> getUndefChanges() {
    return changes.where((change) => change.isMy == -1).toList();
  }

  List<dynamic> getOtherChanges() {
    return changes.where((change) => change.isMy == 0).toList();
  }

  void insertInUnitPlan(SharedPreferences sharedPreferences) {
    for (int i = 0; i < changes.length; i++)
      changes[i].setFilter(sharedPreferences);
  }

  void setColors() {
    for (int i = 0; i < changes.length; i++) changes[i].setColor();
  }
}

class Change {
  final int unit;
  final String lesson;
  final String course;
  String room;
  String teacher;
  final Changed changed;
  final String weekday;
  int isMy = -1; // -1: undefined, 0: not my, 1: my
  UnitPlanSubject normalSubject;
  Color color;

  Change(
      {this.unit,
      this.lesson,
      this.course,
      this.room,
      this.teacher,
      this.changed,
      this.weekday});

  factory Change.fromJson(Map<String, dynamic> json, String _weekday) {
    return Change(
        unit: json['unit'] as int,
        lesson: json['subject'] as String,
        course: json['course'] as String,
        room: json['room'] as String,
        teacher: json['participant'] as String,
        changed: Changed.fromJson(json['change']),
        weekday: _weekday);
  }

  UnitPlanSubject getNormalSubject() {
    return normalSubject;
  }

  void setColor() {
    if (changed.info.toLowerCase().contains('klausur'))
      color = Colors.red;
    else if (changed.info.toLowerCase().contains('freistunde'))
      color = null;
    else
      color = Colors.orange;
  }

  void setFilter(SharedPreferences sharedPreferences) {
    // Set the category of this change...
    setColor();
    int day = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag']
        .indexOf(weekday);

    // Check if the course set...
    UnitPlan.days.forEach((day) => day.lessons.forEach((lesson) {
          if (lesson.subjects.length > 0) {
            int selected = sharedPreferences.getInt(Keys.unitPlan +
                    sharedPreferences.getString(Keys.grade) +
                    '-' +
                    ((lesson.subjects[0].block == '')
                        ? (UnitPlan.days.indexOf(day).toString() +
                            '-' +
                            (day.lessons.indexOf(lesson)).toString())
                        : (lesson.subjects[0].block))) ??
                lesson.subjects.length;
            if (selected < lesson.subjects.length) {
              UnitPlanSubject subject = lesson.subjects[selected];
              if (this.lesson == subject.lesson &&
                  (teacher.length == 0 || teacher == subject.teacher)) {
                // It's the correct lesson...
                if (course == subject.course) {
                  if (changed.info.toLowerCase().contains('klausur')) {
                    if (!(sharedPreferences.getBool(
                            Keys.exams + subject.lesson.toUpperCase()) ??
                        true)) {
                      isMy = 0;
                      return;
                    }
                  }
                  isMy = 1;
                  return;
                } else if (course.length > 0) {
                  isMy = 0;
                  return;
                }
              }
            }
          }
        }));

    // With the current database it is not possible to filter exams...
    if (changed.info.toLowerCase().contains('klausur')) {
      int countSubjects = 0;
      int selectedSubjects = 0;
      bool writing = false;
      UnitPlan.days.forEach((day) =>
          day.lessons.forEach((lesson) => lesson.subjects.forEach((subject) {
                if (subject.lesson == this.lesson &&
                    subject.teacher == this.teacher) {
                  int selected = sharedPreferences.getInt(Keys.unitPlan +
                      sharedPreferences.getString(Keys.grade) +
                      '-' +
                      ((subject.block == '')
                          ? (UnitPlan.days.indexOf(day).toString() +
                              '-' +
                              (day.lessons.indexOf(lesson)).toString())
                          : (subject.block)));
                  countSubjects++;
                  if (selected == null) {
                    isMy = 0;
                    return;
                  }
                  if (selected < lesson.subjects.length) {
                    if (lesson.subjects[selected] == subject) {
                      selectedSubjects++;
                      bool exams = sharedPreferences.getBool(
                              Keys.exams + subject.lesson.toUpperCase()) ??
                          true;
                      writing = exams;
                    }
                  }
                }
              })));
      if ((selectedSubjects >= countSubjects - 1) && writing) {
        isMy = 1;
        UnitPlan.days[day].lessons[unit].subjects
            .forEach((subject) => subject.changes.add(this));
      } else if (selectedSubjects == 0 || !writing) isMy = 0;
      return;
    }

    UnitPlanLesson nLesson = UnitPlan.days[day].lessons[unit];
    List<UnitPlanSubject> possibleSubjects = [];
    UnitPlanSubject nSubject;
    for (int i = 0; i < nLesson.subjects.length; i++) {
      UnitPlanSubject subject = nLesson.subjects[i];
      // There is only one Subject with the correct name...
      if (getSubject(subject.lesson) == getSubject(lesson)) {
        if (nLesson.subjects
                .where((j) => getSubject(j.lesson) == getSubject(lesson))
                .toList()
                .length ==
            1) {
          nSubject = subject;
          break;
        } else
          possibleSubjects.addAll(nLesson.subjects
              .where((j) => getSubject(j.lesson) == getSubject(lesson))
              .toList());
      }
      // There is only one Subject with the correct room...
      if (subject.room == room) {
        if (nLesson.subjects.where((j) => j.room == room).toList().length ==
            1) {
          nSubject = subject;
          break;
        } else
          possibleSubjects
              .addAll(nLesson.subjects.where((j) => j.room == room).toList());
      }
      // There is only one Subject with the correct teacher...
      if (subject.teacher == teacher) {
        if (nLesson.subjects
                .where((j) => j.teacher == teacher)
                .toList()
                .length ==
            1) {
          nSubject = subject;
          break;
        } else
          possibleSubjects.addAll(
              nLesson.subjects.where((j) => j.teacher == teacher).toList());
      }
    }

    isMy = -1;
    if (nSubject != null) {
      int selected = sharedPreferences.getInt(Keys.unitPlan +
          sharedPreferences.getString(Keys.grade) +
          '-' +
          ((nSubject.block == '')
              ? (day.toString() + '-' + (unit).toString())
              : (nSubject.block)));
      if (selected == null) {
        isMy = 0;
        return;
      }
      // If the normal Subject is the selected subject, the subject is my subject...
      if (UnitPlan.days[day].lessons[unit].subjects[selected] == nSubject) {
        isMy = 1;
      } else
        isMy = 0;

      // Add the change to the normal subject...
      nSubject.changes.add(this);

      // Add new information to this change...
      normalSubject = nSubject;
      room = nSubject.room;
      teacher = nSubject.teacher;
    }
    // If there are more than one possibilty and no one is selected, it's sure that it isn't my change...
    else if (possibleSubjects.length > 0) {
      int selected = sharedPreferences.getInt(Keys.unitPlan +
          sharedPreferences.getString(Keys.grade) +
          '-' +
          ((possibleSubjects[0].block == '')
              ? (day.toString() + '-' + (unit).toString())
              : (possibleSubjects[0].block)));
      if (selected == null) {
        isMy = 0;
        return;
      }
      // If the normal Subject is the selected subject, the subject is my subject...
      if (!possibleSubjects
          .contains(UnitPlan.days[day].lessons[unit].subjects[selected])) {
        isMy = 0;
      }
    }
  }
}

class Changed {
  final String info;
  final String teacher;
  final String room;
  final String subject;

  Changed({this.info, this.teacher, this.room, this.subject});

  factory Changed.fromJson(Map<String, dynamic> json) {
    return Changed(
        info: json['info'] as String,
        teacher: json['teacher'] as String,
        room: json['room'] as String,
        subject: json['subject'] as String);
  }
}
