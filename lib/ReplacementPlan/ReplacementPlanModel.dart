import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Subjects.dart';
import '../UnitPlan/UnitPlanModel.dart';

// Describes the replacement plan
class ReplacementPlan {
  static List<ReplacementPlanDay> days;

  // Updates the changes filter...
  static void update(SharedPreferences sharedPreferences) {
    UnitPlan.resetChanges();
    days.forEach((day) => day.insertInUnitPlan(sharedPreferences));
  }
}

// Describes a day of the replacement plan...
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

  // Returns all my changes...
  List<dynamic> getMyChanges() {
    return changes.where((change) => change.isMy == 1).toList();
  }

  // Returns all unsorted changes...
  List<dynamic> getUndefChanges() {
    return changes.where((change) => change.isMy == -1).toList();
  }

  // Get all other changes...
  List<dynamic> getOtherChanges() {
    return changes.where((change) => change.isMy == 0).toList();
  }

  // Insert the replacement plan in the unit plan...
  void insertInUnitPlan(SharedPreferences sharedPreferences) {
    for (int i = 0; i < changes.length; i++)
      changes[i].setFilter(sharedPreferences);
  }

  // Set the category colors of the changes...
  void setColors() {
    for (int i = 0; i < changes.length; i++) changes[i].setColor();
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

  // Returns the normal subject in the unit plan...
  UnitPlanSubject getNormalSubject() {
    return normalSubject;
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

  // Fitler the change (MyChang / UndefChange / OtherChange)...
  void setFilter(SharedPreferences sharedPreferences) {
    // Set the category of this change...
    setColor();

    // Get index of weekday...
    int day = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag']
        .indexOf(weekday);

    // Filter all changes with a set course...
    if (course.length > 0) {
      UnitPlan.days.forEach((day) => day.lessons.forEach((lesson) {
            if (lesson.subjects.length > 0) {
              // Get the selected index...
              int selected = getSelectedSubject(
                      sharedPreferences,
                      lesson.subjects[0],
                      UnitPlan.days.indexOf(day),
                      day.lessons.indexOf(lesson)) ??
                  0;

              // When there is a subject with the right index and this subject has the correct course, set change to myChange...
              if (selected < lesson.subjects.length) {
                UnitPlanSubject subject = lesson.subjects[selected];
                // Subject is the same and teacher is same or not available
                if (this.lesson == subject.lesson &&
                    (teacher == "" || teacher == subject.teacher)) {
                  // It's the correct lesson...
                  if (course == subject.course) {
                    // Change is exam
                    if (changed.info.toLowerCase().contains('klausur')) {
                      // The subject is selected as not writing
                      if (!(sharedPreferences.getBool(Keys.exams(subject.lesson.toUpperCase())) ?? true)) {
                        isMy = 0;
                        return;
                      }
                    }
                    isMy = 1;
                  } else {
                    // Courses are not the same
                    isMy = 0;
                  }
                }
              }
            }
        }));
      if (isMy != -1) {
        return;
      }
    }

    // Filter all exams...
    if (changed.info.toLowerCase().contains('klausur')) {
      int countSubjects = 0;
      int selectedSubjects = 0;
      bool writing = sharedPreferences.getBool(Keys.exams(lesson.toUpperCase())) ?? true;

      if (!writing) {
        isMy = 0;
        return;
      }  
      // Search all subjects with the correct name and teacher...
      UnitPlan.days.forEach((day) =>
          day.lessons.forEach((lesson) => lesson.subjects.forEach((subject) {
                // Change subject and change teacher are the same as in the current lesson
                if (subject.lesson == this.lesson &&
                    subject.teacher == this.teacher) {
                  // Get selected index...
                  int selected = getSelectedSubject(sharedPreferences, subject,
                      UnitPlan.days.indexOf(day), day.lessons.indexOf(lesson));

                  // Count the possible subjects...
                  countSubjects++;
                  if (selected == null) {
                    isMy = -1;
                    return;
                  }
                  // Count selected subjects...
                  if (lesson.subjects[selected] == subject) {
                    selectedSubjects++;
                  }
                }
              })));
      // If max one of the subjects is not installed, set this change to myChange...
      if (selectedSubjects >= countSubjects - 1) {
        isMy = 1;
        // Add this change to the subjects in the unit plan...
        UnitPlan.days[day].lessons[unit].subjects
            .forEach((subject) => subject.changes.add(this));
      } else if (selectedSubjects == 0) isMy = 0;
      return;
    }

    // Filter all other changes...
    // Get the normal lesson...
    UnitPlanLesson nLesson = UnitPlan.days[day].lessons[unit];
    List<UnitPlanSubject> possibleSubjects = [];
    UnitPlanSubject nSubject;

    // Add all subjects with the correct lesson
    List<UnitPlanSubject> sameLessons = nLesson.subjects
              .where((j) => getSubject(j.lesson) == getSubject(lesson))
              .toList();

    // Add all subjects with the correct room
    List<UnitPlanSubject> sameRooms = nLesson.subjects
              .where((j) => j.room == room)
              .toList();

    // Add all subjects with the correct teacher
    List<UnitPlanSubject> sameTeachers = nLesson.subjects
              .where((j) => j.teacher == teacher)
              .toList();
    
    if (sameLessons.length == 1) {
      nSubject = sameLessons[0];
    }
    if (sameRooms.length == 1) {
      nSubject = sameRooms[0];
    }
    if (sameTeachers.length == 1) {
      nSubject = sameTeachers[0];
    }
    
    possibleSubjects.addAll(sameLessons);
    possibleSubjects.addAll(sameRooms);
    possibleSubjects.addAll(sameTeachers);

    // If a normal subject found, set change to myChange and insert in untiplan...
    if (nSubject != null) {
      // Get selected
      int selected = getSelectedSubject(sharedPreferences, nSubject, day, unit);
      if (selected != null) {
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
    }
    // If there is more than one possibilty and no one is selected, it's sure that it isn't my change...
    else if (possibleSubjects.length > 0) {
      int selected = getSelectedSubject(sharedPreferences, possibleSubjects[0], day, unit);
      if (selected != null) {
        // If the normal Subject is the selected subject, the subject is my subject...
        if (!possibleSubjects.contains(UnitPlan.days[day].lessons[unit].subjects[selected])) {
          isMy = 0;
        }
      }
    }
  }
}

// Describes a changed of a replacement plan change...
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

// Returns the selected subject index...
int getSelectedSubject(SharedPreferences sharedPreferences,
    UnitPlanSubject subject, int day, int unit) {
  // If the subject block is set, get index for block, else get index for day + unit...
  return sharedPreferences.getInt(Keys.unitPlan(sharedPreferences.getString(Keys.grade), block: subject.block, day: day, unit: unit));
}
