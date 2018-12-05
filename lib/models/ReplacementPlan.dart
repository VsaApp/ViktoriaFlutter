import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UnitPlan.dart';
import '../Subjects.dart';
import '../Keys.dart';

class ReplacementPlan {
  static List<ReplacementPlanDay> days;

  static void update(SharedPreferences sharedPreferences){
    UnitPlan.resetChanges();
    days.forEach((day) => day.insertInUnitPlan(sharedPreferences));
  }

  static void updateFilter(UnitPlanDay day, UnitPlanLesson lesson, SharedPreferences sharedPreferences){
    ReplacementPlanDay replacementPlanDay = days[0].weekday == day.name ? days[0] : days[1];
    replacementPlanDay.changes.where((change) => change.unit-1 == day.lessons.indexOf(lesson)).forEach((c) => c.setFilter(sharedPreferences));
  }
}

class ReplacementPlanDay {
  final String date;
  final String time;
  final String update;
  final String weekday;
  final List<dynamic> changes;

  ReplacementPlanDay({this.date, this.time, this.update, this.weekday, this.changes});

  factory ReplacementPlanDay.fromJson(Map<String, dynamic> json) {
    return ReplacementPlanDay(
      date: json['date'] as String,
      time: json['time'] as String,
      update: json['update'] as String,
      weekday: json['weekday'] as String,
      changes: json['changes'].map((i) => Change.fromJson(i, (json['weekday'] as String))).toList(),
    );
  }

  List<dynamic> getMyChanges(){
    return changes.where((change) => change.isMy == 1).toList();
  }

  List<dynamic> getUndefChanges(){
    return changes.where((change) => change.isMy == -1).toList();
  }

  List<dynamic> getOtherChanges(){
    return changes.where((change) => change.isMy == 0).toList();
  }

  void insertInUnitPlan(SharedPreferences sharedPreferences){
    for (int i = 0; i < changes.length; i++) changes[i].setFilter(sharedPreferences);
  }
}

class Change {
  final String grade;
  final int unit;
  final String lesson;
  final String type;
  String room;
  String teacher;
  final Changed changed;
  final String weekday;
  int isMy = -1; // -1: undefined, 0: not my, 1: my
  UnitPlanSubject normalSubject;
  Color color;

  Change({this.grade, this.unit, this.lesson, this.type, this.room, this.teacher, this.changed, this.weekday});

  factory Change.fromJson(Map<String, dynamic> json, String _weekday) {
    return Change(
      grade: json['grade'] as String,
      unit: json['unit'] as int,
      lesson: json['lesson'] as String,
      type: json['type'] as String,
      room: json['room'] as String,
      teacher: json['teacher'] as String,
      changed: Changed.fromJson(json['changed']),
      weekday: _weekday
    );
  }

  UnitPlanSubject getNormalSubject(){
    return normalSubject;
  }

  void setColor(){
    if (changed.info.toLowerCase().contains('klausur')) color = Colors.red;
    else if (changed.info.toLowerCase().contains('freistunde')) color = null;
    else color = Colors.orange;
  }

  void setFilter(SharedPreferences sharedPreferences){
    // Set the category of this change...
    setColor();
    int day = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag'].indexOf(weekday);

    // With the current database it is not possible to filter exams...
    if (changed.info.toLowerCase().contains('klausur')) {
      bool allSelected = true;
      bool nothingSelected = true;
      bool writing = false;
      UnitPlan.days.forEach((day) => day.lessons.forEach((lesson) => lesson.subjects.forEach((subject) {
        if (subject.lesson == this.lesson && subject.teacher == this.teacher){
          int selected = sharedPreferences.getInt(Keys.unitPlan +
                              sharedPreferences.getString(Keys.grade) + '-' +
                              ((subject.block == null) ? (day.toString() + '-' + (day.lessons.indexOf(lesson)).toString()) : (subject.block)));
          if (lesson.subjects.length <= selected) allSelected = false;
          else if (lesson.subjects[selected] == subject){
            nothingSelected = false;
          }
          else allSelected = false;
          if (allSelected) {
            bool exams = (subject.block != null) ? sharedPreferences.getBool(Keys.exams + subject.block + subject.teacher) : null;
            writing = writing || ((exams == null) ? true : exams);
          }
        }
      })));
      if (allSelected && writing) {
        isMy = 1;
        UnitPlan.days[day].lessons[unit - 1].subjects.forEach((subject) => subject.change = this);
      }
      else if (nothingSelected || !writing) isMy = 0;
      return;
    };

    UnitPlanLesson nLesson = UnitPlan.days[day].lessons[unit - 1];
    List<UnitPlanSubject> possibleSubjects = [];
    UnitPlanSubject nSubject;
    for (int i = 0; i < nLesson.subjects.length; i++){
      UnitPlanSubject subject = nLesson.subjects[i];
      // There is only one Subject with the correct name...
      if (getSubject(subject.lesson) == getSubject(lesson)){
        if (nLesson.subjects.where((j) => getSubject(j.lesson) == getSubject(lesson)).toList().length == 1){
          nSubject = subject;
          break;
        }
        else possibleSubjects.addAll(nLesson.subjects.where((j) => getSubject(j.lesson) == getSubject(lesson)).toList());
      }  
      // There is only one Subject with the correct room...
      if (subject.room == room){
        if (nLesson.subjects.where((j) => j.room == room).toList().length == 1){
          nSubject = subject;
          break;
        }
        else possibleSubjects.addAll(nLesson.subjects.where((j) => j.room == room).toList());
      }  
      // There is only one Subject with the correct teacher...
      if (subject.teacher == teacher){
        if (nLesson.subjects.where((j) => j.teacher == teacher).toList().length == 1){
        nSubject = subject;
        break;
        }
        else possibleSubjects.addAll(nLesson.subjects.where((j) => j.teacher == teacher).toList());
      }  
    }

    isMy = -1;
    if (nSubject != null){
      int selected = sharedPreferences.getInt(Keys.unitPlan +
                          sharedPreferences.getString(Keys.grade) + '-' +
                          ((nSubject.block == null) ? (day.toString() + '-' + (unit - 1).toString()) : (nSubject.block)));
      // If the normal Subject is the selected subject, the subject is my subject...
      if (UnitPlan.days[day].lessons[unit-1].subjects[(selected == null) ? 0 : selected] == nSubject){
        isMy = 1;
      }
      else isMy = 0;

      // Add the change to the normal subject...
      if (nSubject.change == null) nSubject.change = this;

      // Add new information to this change...
      normalSubject = nSubject;
      room = nSubject.room;
      teacher = nSubject.teacher;
    }
    // If there are more than one possibilty and no one is selected, it's sure that it isn't my change...
    else if (possibleSubjects.length > 0){
      int selected = sharedPreferences.getInt(Keys.unitPlan +
                          sharedPreferences.getString(Keys.grade) + '-' +
                          ((possibleSubjects[0].block == null) ? (day.toString() + '-' + (unit - 1).toString()) : (possibleSubjects[0].block)));
      // If the normal Subject is the selected subject, the subject is my subject...
      if (!possibleSubjects.contains(UnitPlan.days[day].lessons[unit-1].subjects[(selected == null) ? 0 : selected])){
        isMy = 0;
      }
    }
  }
}

class Changed {
  final String info;
  final String teacher;
  final String room;

  Changed({this.info, this.teacher, this.room});

  factory Changed.fromJson(Map<String, dynamic> json) {
    return Changed(
      info: json['info'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String
    );
  }
}
