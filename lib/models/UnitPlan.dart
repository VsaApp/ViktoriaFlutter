import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import 'ReplacementPlan.dart';

// Describes the whole unit plan...
class UnitPlan {
  static List<UnitPlanDay> days;

  // Delete all changes in the unit plan...
  static void resetChanges() {
    days.forEach((day) => day.lessons.forEach((lesson) => lesson.subjects
        .forEach((subject) => subject.changes = [].cast<Change>())));
  }

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

  UnitPlanDay({this.name, this.lessons});

  factory UnitPlanDay.fromJson(Map<String, dynamic> json) {
    return UnitPlanDay(
      name: json['weekday'] as String,
      lessons: json['lessons']
          .values
          .toList()
          .map((i) => UnitPlanLesson.fromJson(i))
          .toList(),
    );
  }

  // Set the default selections...
  void setSelections(int day, SharedPreferences sharedPreferences) {
    for (int i = 0; i < lessons.length; i++) {
      lessons[i].setSelection(day, i, sharedPreferences);
    }
  }
}

// Describes a Lesson of a unit plan day...
class UnitPlanLesson {
  final List<UnitPlanSubject> subjects;

  UnitPlanLesson({this.subjects});

  factory UnitPlanLesson.fromJson(List<dynamic> json) {
    return UnitPlanLesson(
      subjects: json.map((i) => UnitPlanSubject.fromJson(i)).toList(),
    );
  }

  // Set the default selection...
  void setSelection(int day, int unit, SharedPreferences sharedPreferences) {
    String prefKey = Keys.unitPlan +
        sharedPreferences.getString(Keys.grade) +
        '-' +
        (subjects[0].block == ''
            ? day.toString() + '-' + unit.toString()
            : subjects[0].block);
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
  List<Change> changes = [];

  UnitPlanSubject(
      {this.teacher, this.lesson, this.room, this.block, this.course});

  factory UnitPlanSubject.fromJson(Map<String, dynamic> json) {
    return UnitPlanSubject(
        teacher: json['participant'] as String,
        lesson: json['subject'] as String,
        room: json['room'] as String,
        block: json['block'] as String,
        course: json['course'] as String);
  }
}
