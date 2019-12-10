/// Describes the teacher list
class Teacher {
  // ignore: public_member_api_docs
  final String shortName;
  // ignore: public_member_api_docs
  final List<String> subjects;
  // ignore: public_member_api_docs
  Teacher({this.shortName, this.subjects}) : super();

  /// Creates teacher list from json map
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      shortName: json['shortName'] as String,
      subjects: [],
    );
  }
}
