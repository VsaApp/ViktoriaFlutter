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
      changes: json['changes'].map((i) => Change.fromJson(i)).toList(),
    );
  }
}

class Change {
  final String grade;
  final int unit;
  final String lesson;
  final String type;
  final String room;
  final String teacher;
  final Changed changed;

  Change({this.grade, this.unit, this.lesson, this.type, this.room, this.teacher, this.changed});

  factory Change.fromJson(Map<String, dynamic> json) {
    return Change(
      grade: json['grade'] as String,
      unit: json['unit'] as int,
      lesson: json['lesson'] as String,
      type: json['type'] as String,
      room: json['room'] as String,
      teacher: json['teacher'] as String,
      changed: Changed.fromJson(json['changed'])
    );
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
