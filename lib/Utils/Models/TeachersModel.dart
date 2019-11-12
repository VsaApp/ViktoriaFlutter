
class Teacher {
  final String shortName;
  final List<String> subjects;
  Teacher({this.shortName, this.subjects}) : super();

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      shortName: json['shortName'] as String,
      subjects: [],
    );
  }
}
