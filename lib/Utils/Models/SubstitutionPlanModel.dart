import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

// Describes the substitution plan
class SubstitutionPlan {
  final List<SubstitutionPlanDay> days;

  void updateFilter() {
    days.forEach((day) => day.filterSubstitutions());
  }

  void insert() {
    Data.timetable.getAllSubjects(reset: true);
    days.forEach((day) => day.insertInTimetable());
  }

  SubstitutionPlan({@required this.days});
}

// Describes a day of the substitution plan...
class SubstitutionPlanDay {
  final DateTime date;
  final DateTime updated;
  final int week;
  final Map<String, List<String>> unparsed;
  final Map<String, List<Substitution>> data;
  final bool isEmpty;
  List<Substitution> myChanges;
  List<Substitution> undefinedChanges;
  List<Substitution> otherChanges;
  List<String> myUnparsed;
  String filteredGrade;

  SubstitutionPlanDay(
      {@required this.date,
      @required this.updated,
      @required this.data,
      @required this.week,
      @required this.unparsed,
      @required this.isEmpty}) {
    insertInTimetable();
    filterSubstitutions();
    filterUnparsed();
  }

  void insertInTimetable() {
    List<TimetableSubject> subjects = Data.timetable.getAllSubjects();
    List<String> subjectsIds = subjects.map((s) => s.id).toList();
    List<String> subjectsCourseIDs = subjects.map((s) => s.courseID).toList();

    filteredGrade = Data.timetable.grade;
    data[filteredGrade].forEach((substitution) {
      if (substitution.id != null && subjectsIds.contains(substitution.id)) {
        subjects[subjectsIds.indexOf(substitution.id)]
            .substitutions
            .add(substitution);
      } else if (substitution.courseID != null &&
          subjectsCourseIDs.contains(substitution.courseID)) {
        List<TimetableSubject> _subjects =
            subjects.where((s) => s.courseID == substitution.courseID).toList();
        try {
          _subjects
              .where((s) =>
                  s.day == date.weekday - 1 && s.unit == substitution.unit)
              .single
              .substitutions
              .add(substitution);
        } on StateError catch (_) {
          Data.timetable.days[date.weekday - 1].units[substitution.unit]
              .substitutions
              .add(substitution);
        }
      }
    });
  }

  List<String> filterUnparsed({String grade}) {
    myUnparsed = [];
    if (grade == null) {
      filteredGrade = Data.timetable.grade;
      myUnparsed.addAll(unparsed[filteredGrade]);
      myUnparsed.addAll(unparsed['other']);
      return null;
    }
    return []..addAll(unparsed[grade]..addAll(unparsed['other']));
  }

  void filterSubstitutions() {
    myChanges = [];
    otherChanges = [];
    undefinedChanges = [];

    List<TimetableSubject> selectedSubjects =
        Data.timetable.getAllSelectedSubjects();
    List<String> selectedIds = selectedSubjects.map((s) => s.id).toList();
    List<String> selectedCourseIds =
        selectedSubjects.map((s) => s.courseID).toList();

    filteredGrade = Data.timetable.grade;
    data[filteredGrade].forEach((substitution) {
      if (substitution.id == null && substitution.courseID == null) {
        undefinedChanges.add(substitution);
      } else if ((substitution.id != null &&
              selectedIds.contains(substitution.id)) ||
          (substitution.courseID != null &&
              selectedCourseIds.contains(substitution.courseID))) {
        myChanges.add(substitution);
      } else {
        otherChanges.add(substitution);
      }
    });
  }

  factory SubstitutionPlanDay.fromJson(Map<String, dynamic> json) {
    return SubstitutionPlanDay(
        date: DateTime.parse(json['date'] as String).toLocal(),
        updated: DateTime.parse(json['updated'] as String).toLocal(),
        unparsed: json['unparsed'].map<String, List<String>>(
            (String key, value) =>
                MapEntry<String, List<String>>(key, value.cast<String>())),
        data: json['data'].map<String, List<Substitution>>(
            (String key, value) => MapEntry<String, List<Substitution>>(
                key,
                value
                    .map<Substitution>((json) => Substitution.fromJson(json))
                    .toList())),
        week: json['week'] as int,
        isEmpty: false);
  }
}

// Describes a substitution of a substitution plan day...
class Substitution {
  /// starts with 0; 6. unit is the lunch break
  final int unit;

  /// 0 => substitution; 1 => free lesson; 2 => exam
  final int type;
  final String info;
  final String id;
  final String courseID;
  final SubstitutionDetails original;
  final SubstitutionDetails changed;

  Color get color => type == 0 ? Colors.orange : type == 1 ? null : Colors.red;

  bool get isExam => type == 2;

  bool get sure => id != null;

  bool equals(Substitution c) {
    return unit == c.unit &&
        type == c.type &&
        courseID == c.courseID &&
        info == c.info &&
        id == c.id;
  }

  Substitution(
      {@required this.unit,
      @required this.type,
      @required this.info,
      @required this.id,
      @required this.courseID,
      @required this.original,
      @required this.changed});

  factory Substitution.fromJson(Map<String, dynamic> json) {
    return Substitution(
      unit: json['unit'] as int,
      type: json['type'] as int,
      info: json['info'] as String,
      id: json['id'] as String,
      courseID: json['courseID'] as String,
      original: SubstitutionDetails.fromJson(json['original']),
      changed: SubstitutionDetails.fromJson(json['changed']),
    );
  }
}

// Describes details of a substitution...
class SubstitutionDetails {
  final String teacherID;
  final String roomID;
  final String subjectID;

  bool equals(SubstitutionDetails c) {
    return teacherID == c.teacherID &&
        roomID == c.roomID &&
        subjectID == c.subjectID;
  }

  SubstitutionDetails({
    @required this.teacherID,
    @required this.roomID,
    @required this.subjectID,
  });

  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) {
    return SubstitutionDetails(
      teacherID: json['teacherID'] as String,
      roomID: json['roomID'] as String,
      subjectID: json['subjectID'] as String,
    );
  }
}
