import 'ReplacementPlan.dart';

class UnitPlan {
  static List<UnitPlanDay> days;
}

class UnitPlanDay {
  final String name;
  final List<dynamic> lessons;

  UnitPlanDay({this.name, this.lessons});

  factory UnitPlanDay.fromJson(Map<String, dynamic> json) {
    return UnitPlanDay(
      name: json['name'] as String,
      lessons: json['lessons'].map((i) => UnitPlanLesson.fromJson(i)).toList(),
    );
  }
}

class UnitPlanLesson {
  final List<UnitPlanSubject> subjects;

  UnitPlanLesson({this.subjects});

  factory UnitPlanLesson.fromJson(List<dynamic> json) {
    return UnitPlanLesson(
      subjects: json.map((i) => UnitPlanSubject.fromJson(i)).toList(),
    );
  }
}

class UnitPlanSubject {
  final String teacher;
  final String lesson;
  final String room;
  final String block;
  Change change;

  UnitPlanSubject({this.teacher, this.lesson, this.room, this.block});

  factory UnitPlanSubject.fromJson(Map<String, dynamic> json) {
    return UnitPlanSubject(
      teacher: json['teacher'] as String,
      lesson: json['lesson'] as String,
      room: json['room'] as String,
      block: json['block'] as String,
    );
  }
}
