/// All tags of the current user
class Tags {
  final String grade;
  final int group;

  /// List of course ids
  final List<String> selected;

  /// List of course ids
  final List<String> exams;

  /// Cafetoria login data
  final CafetoriaTags cafetoriaLogin;

  /// Timestamp of last tags modified
  final DateTime timestamp;

  Tags({
    this.group,
    this.grade,
    this.selected,
    this.exams,
    this.cafetoriaLogin,
    this.timestamp,
  });

  bool get isInitialized => grade != null;

  factory Tags.fromJson(Map<String, dynamic> json) {
    if (json.keys.isEmpty) return Tags();
    return Tags(
      grade: json['grade'] as String,
      group: json['group'] as int,
      cafetoriaLogin: CafetoriaTags.fromJson(json['cafetoria']),
      selected: json['selected'].cast<String>().toList(),
      exams: json['exams'].cast<String>().toList(),
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

class CafetoriaTags {
  final String id;
  final String password;
  final DateTime timestamp;

  CafetoriaTags({this.id, this.password, this.timestamp});

  factory CafetoriaTags.fromJson(Map<String, dynamic> json) {
    return CafetoriaTags(
      id: json['id'] as String,
      password: json['password'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'timestamp': timestamp.toIso8601String()
    };
  }
}
