/// All tags of the current user
class Tags {
  /// The user grade
  final String grade;

  /// The user group (pupil/developer/teacher)
  final int group;

  /// List of course ids
  final List<String> selected;

  /// List of course ids
  final List<String> exams;

  /// Cafetoria login data
  final CafetoriaTags cafetoriaLogin;

  /// Timestamp of last tags modified
  final DateTime timestamp;

  // ignore: public_member_api_docs
  Tags({
    this.group,
    this.grade,
    this.selected,
    this.exams,
    this.cafetoriaLogin,
    this.timestamp,
  });

  /// Checks if the user is already initialized in the server
  bool get isInitialized => grade != null;

  /// Creates the tags model from json map
  factory Tags.fromJson(Map<String, dynamic> json) {
    if (json.keys.isEmpty) {
      return Tags();
    }
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

/// Describes a device
class Device {
  // ignore: public_member_api_docs
  final String os;
  // ignore: public_member_api_docs
  final String name;
  // ignore: public_member_api_docs
  final String appVersion;
  // ignore: public_member_api_docs
  final bool notifications;
  // ignore: public_member_api_docs
  final String firebaseId;
  // ignore: public_member_api_docs
  final String language;

  // ignore: public_member_api_docs
  Device(
      {this.os,
      this.name,
      this.appVersion,
      this.notifications,
      this.firebaseId,
      this.language});

  /// Creates a device from json map
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

  /// Convert a device to a json map
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

/// Describes the cafetoria tags
class CafetoriaTags {
  // ignore: public_member_api_docs
  final String id;
  // ignore: public_member_api_docs
  final String password;

  /// Last updated timestamp
  final DateTime timestamp;

  // ignore: public_member_api_docs
  CafetoriaTags({this.id, this.password, this.timestamp});

  /// Creates cafetoria tags from json map
  factory CafetoriaTags.fromJson(Map<String, dynamic> json) {
    return CafetoriaTags(
        id: json['id'] as String,
        password: json['password'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String));
  }

  /// Converts cafetoria tags to json map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'timestamp': timestamp.toIso8601String()
    };
  }
}
