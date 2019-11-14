/// All tags of the current user
class Tags {
  final String grade;
  final int group;
  /// List of course ids
  final List<String> selected;
  /// List of course ids
  final List<String> exams;
  /// Timestamp of last tags modified
  final DateTime timestamp;

  Tags({
      this.group,
      this.grade,
      this.selected,
      this.exams,
      this.timestamp,});

  bool get isInitialized => grade != null;

  factory Tags.fromJson(Map<String, dynamic> json) {
    if (json.keys.isEmpty) return Tags();
    return Tags(
        grade: json['grade'] as String,
        group: json['group'] as int,
        selected: json['selected'].cast<String>().toList(),
        exams:
            json['exams'].cast<String>().toList(),
        timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class Device {
  final String os;
  final String name;
  final String appVersion;
  final bool notifications;
  final String firebaseId;
  final String language;

  Device(
      {this.os,
      this.name,
      this.appVersion,
      this.notifications,
      this.firebaseId,
      this.language});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      os: json['os'] as String,
      name: json['name'] as String,
      appVersion: json['appVersion'] as String,
      notifications: json['notifications'] as bool,
      firebaseId: json['firebaseId'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'os': os,
      'name': name,
      'appVersion': appVersion,
      'notifications': notifications,
      'firebaseId': firebaseId,
      'language': language,
    };
  }
}
