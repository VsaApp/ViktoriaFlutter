import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

/// Describes the substitution plan
class SubstitutionPlan {
  /// All substitution plan days
  final List<SubstitutionPlanDay> days;

  /// Updates the substitution plan filter
  void updateFilter() {
    days.forEach((day) => day.filterSubstitutions());
  }

  /// Inserts the substitution plan into the timetable
  void insert() {
    Data.timetable.resetAllSelections();
    days.forEach((day) => day.insertInTimetable());
  }

  // ignore: public_member_api_docs
  SubstitutionPlan({@required this.days});
}

/// Describes a day of the substitution plan...
class SubstitutionPlanDay {
  /// The [date] of the day
  final DateTime date;

  /// The [updated] date of the day
  final DateTime updated;

  /// The (A: 0; B: 1) [week]
  final int week;

  /// All unparsed substitutions in a grade map (+other for undefined grade)
  final Map<String, List<String>> unparsed;

  /// All substitutions in a grade map
  final Map<String, List<Substitution>> data;

  /// Is an empty day
  final bool isEmpty;

  /// The filtered substitutions for the user
  List<Substitution> myChanges;

  /// The undefined filtered substitutions
  List<Substitution> undefinedChanges;

  /// The other filtered substitutions
  List<Substitution> otherChanges;

  /// The filtered unparsed substitutions
  List<String> myUnparsed;

  /// The current user grade
  String filteredGrade;

  // ignore: public_member_api_docs
  SubstitutionPlanDay(
      {@required this.date,
      @required this.updated,
      @required this.data,
      @required this.week,
      @required this.unparsed,
      @required this.isEmpty}) {
    if (isEmpty) {
      return;
    }
    sort();
    insertInTimetable();
    filterSubstitutions();
    filterUnparsed();
  }

  /// Sorts all substitutions by the unit
  void sort() {
    data.forEach((String grade, List<Substitution> substitutions) {
      substitutions.sort(
          (s1, s2) => s1.unit < s2.unit ? -1 : s1.unit == s2.unit ? 0 : 1);
    });
  }

  /// Insert the substitutions into the timetable
  void insertInTimetable() {
    print('insert ${date.weekday}');
    final List<TimetableSubject> subjects = Data.timetable.getAllSubjects();
    final List<String> subjectsIds = subjects.map((s) => s.id).toList();
    final List<String> subjectsCourseIDs =
        subjects.map((s) => s.courseID).toList();

    filteredGrade = Data.timetable.grade;
    data[filteredGrade].forEach((substitution) {
      if (substitution.id != null && subjectsIds.contains(substitution.id)) {
        subjects[subjectsIds.indexOf(substitution.id)]
            .substitutions
            .add(substitution);
      } else if (substitution.courseID != null &&
          subjectsCourseIDs.contains(substitution.courseID)) {
        final List<TimetableSubject> _subjects =
            subjects.where((s) => s.courseID == substitution.courseID).toList();
        if (_subjects.isNotEmpty) {
          if (Data.timetable.days[date.weekday - 1].units.length <=
              substitution.unit) {
            return;
          }
          Data.timetable.days[date.weekday - 1].units[substitution.unit]
              .substitutions
              .add(substitution);
        }
      }
    });
  }

  /// Set the unparsed filtered lists
  List<String> filterUnparsed({String grade}) {
    print('filter u ${date.weekday}');
    myUnparsed = [];
    if (grade == null) {
      filteredGrade = Data.timetable.grade;
      myUnparsed..addAll(unparsed[filteredGrade])..addAll(unparsed['other']);
      return null;
    }
    return [...unparsed[grade]..addAll(unparsed['other'])];
  }

  /// Set the filtered lists
  void filterSubstitutions() {
    myChanges = [];
    otherChanges = [];
    undefinedChanges = [];

    final List<TimetableSubject> selectedSubjects =
        Data.timetable.getAllSelectedSubjects();
    final List<String> selectedIds = selectedSubjects.map((s) => s.id).toList();
    final List<String> selectedCourseIds =
        selectedSubjects.map((s) => s.courseID).toList();

    filteredGrade = Data.timetable.grade;
    data[filteredGrade].forEach((substitution) {
      if (substitution.id == null && substitution.courseID == null) {
        undefinedChanges.add(substitution);
      } else if ((substitution.id != null &&
              selectedIds.contains(substitution.id)) ||
          (substitution.courseID != null &&
              selectedCourseIds.contains(substitution.courseID))) {
        // If it is no exam, add to my changes
        if (!substitution.isExam) {
          myChanges.add(substitution);
        } else if (selectedSubjects[
                selectedCourseIds.indexOf(substitution.courseID)]
            .writeExams) {
          myChanges.add(substitution);
        } else {
          otherChanges.add(substitution);
        }
      } else {
        otherChanges.add(substitution);
      }
    });
  }

  /// Check if a substitution if for the user
  bool isMySubstitution(Substitution substitution) {
    return myChanges.contains(substitution);
  }

  /// Create substitution from json map
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

/// Describes a substitution of a substitution plan day...
class Substitution {
  /// starts with 0; 6. unit is the lunch break
  final int unit;

  /// 0 => substitution; 1 => free lesson; 2 => exam
  final int type;

  /// The raw substitution information
  final String info;

  /// The timetable id
  final String id;

  /// The timetable courseID
  final String courseID;

  /// The original subject details
  final SubstitutionDetails original;

  /// The changed subject details
  final SubstitutionDetails changed;

  /// Returns the color of the substitution
  Color get color => type == 0 ? Colors.orange : type == 1 ? null : Colors.red;

  /// Check if it is an exam
  bool get isExam => type == 2;

  /// Check if the substitution could be filtered
  bool get sure => id != null && courseID != null;

  /// Compares this substitution to the given substitution
  bool equals(Substitution c) {
    return unit == c.unit &&
        type == c.type &&
        courseID == c.courseID &&
        info == c.info &&
        id == c.id;
  }

  // ignore: public_member_api_docs
  Substitution(
      {@required this.unit,
      @required this.type,
      @required this.info,
      @required this.id,
      @required this.courseID,
      @required this.original,
      @required this.changed});

  /// Creates a substitution from json map
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

/// Describes details of a substitution...
class SubstitutionDetails {
  // ignore: public_member_api_docs
  final String teacherID;
  // ignore: public_member_api_docs
  final String roomID;
  // ignore: public_member_api_docs
  final String subjectID;

  /// Compares to substitution details
  bool equals(SubstitutionDetails c) {
    return teacherID == c.teacherID &&
        roomID == c.roomID &&
        subjectID == c.subjectID;
  }

  // ignore: public_member_api_docs
  SubstitutionDetails({
    @required this.teacherID,
    @required this.roomID,
    @required this.subjectID,
  });

  /// Creates a substitution details from json
  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) {
    return SubstitutionDetails(
      teacherID: json['teacherID'] as String,
      roomID: json['roomID'] as String,
      subjectID: json['subjectID'] as String,
    );
  }
}
