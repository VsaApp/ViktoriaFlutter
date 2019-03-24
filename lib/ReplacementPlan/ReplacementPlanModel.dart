import 'package:flutter/material.dart';

import '../Keys.dart';
import '../Selection.dart';
import '../Storage.dart';
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
  final String weektype;
  final List<Change> myChanges;
  final List<Change> undefinedChanges;
  final List<Change> otherChanges;
  final List<Change> unparsed;
  final isEmpty;

  ReplacementPlanDay({
    @required this.date,
    @required this.weekday,
    @required this.weektype,
    this.time,
    this.update,
    this.myChanges,
    this.undefinedChanges,
    this.otherChanges,
    this.unparsed,
    this.isEmpty = false,
  });
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
  List<dynamic> original;
  List<dynamic> change;

  Color get color {
    if (changed.info.toLowerCase().contains('klausur'))
      return Colors.red;
    else if (changed.info.toLowerCase().contains('freistunde'))
      return null;
    else
      return Colors.orange;
  }

  bool get isExam {
    return changed.info.toLowerCase().contains('klausur');
  }

  bool get isRewriteExam {
    return isExam && changed.info.toLowerCase().contains('nachschreiber');
  }

  int isMyExam(String week) {
    if (isRewriteExam) return -1;
    String grade = Storage.getString(Keys.grade) ?? '';
    if (!(Storage.getBool(Keys.exams(grade, lesson.toUpperCase())) ?? true))
      return 0;

    Map<String, List<int>> courseCount = {};
    int selected = 0;
    bool containsLK = false;
    int count = 0;

    for (int i = 0; i < UnitPlan.days.length; i++) {
      UnitPlanDay day = UnitPlan.days[i];
      for (int j = 0; j < day.lessons.length; j++) {
        UnitPlanLesson lesson = day.lessons[j];
        int _selected = getSelectedIndex(lesson.subjects,
            UnitPlan.days.indexOf(day), day.lessons.indexOf(lesson),
            week: week);
        for (int k = 0; k < lesson.subjects.length; k++) {
          UnitPlanSubject subject = lesson.subjects[k];
          if ((subject.lesson == this.lesson &&
                  subject.course == this.course) ||
              (subject.course.length == 0 &&
                  subject.lesson == this.lesson &&
                  subject.teacher == this.teacher)) {
            containsLK = containsLK ||
                subject.course.toLowerCase().contains('lk') ||
                course.toLowerCase().contains('lk');
            count++;
            if (!courseCount.keys.contains(subject.course))
              courseCount[subject.course] = [0, 1];
            else
              courseCount[subject.course][1]++;
            if (lesson.subjects.indexOf(subject) == _selected) {
              selected++;
              courseCount[subject.course][0]++;
            }
          }
        }
      }
    }

    if (selected == 0) return 0;
    if (selected >= count - 1) return 1;
    for (int i = 0; i < courseCount.keys.length; i++) {
      String key = courseCount.keys.toList()[i];
      if (key == course) {
        if (courseCount[key][0] > 0) return 1;
      }
    }
    if (courseCount.keys.contains('')) {
      if (courseCount[''][0] >= courseCount[''][1] - 1) return 1;
      if (courseCount[''][1] > 3) return -1;
      if (courseCount[''][0] >= 1) return 1;
      return 0;
    } else
      return 0;
  }

  bool equals(Change c) {
    return unit == c.unit &&
        lesson == c.lesson &&
        course == c.course &&
        room == c.room &&
        teacher == c.teacher &&
        changed.equals(c.changed);
  }

  Change({@required this.unit,
    @required this.lesson,
    @required this.course,
    @required this.room,
    @required this.teacher,
    @required this.changed,
    @required this.sure,
    this.original,
    this.change});

  factory Change.fromJson(Map<String, dynamic> json) {
    return Change(
      unit: json['unit'] as int,
      lesson: json['subject'] as String,
      course: json['course'] as String,
      room: json['room'] as String,
      teacher: json['participant'] as String,
      changed: Changed.fromJson(json['change']),
      sure: json['sure'] as bool,
      original: !json.keys.contains('participant')
          ? json['unparsedOriginal'].map((line) => line.toString()).toList()
          : null,
      change: !json.keys.contains('participant')
          ? json['unparsedChange'].map((line) => line.toString()).toList()
          : null,
    );
  }
}

// Describes a changed of a replacement plan change...
class Changed {
  final String info;
  final String teacher;
  final String room;
  final String subject;

  bool equals(Changed c) {
    return info == c.info &&
        teacher == c.teacher &&
        room == c.room &&
        subject == c.subject;
  }

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
