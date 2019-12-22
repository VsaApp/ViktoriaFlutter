/// All tags of the current user
class Tags {
  /// The user grade
  final String grade;

  /// The user group (pupil/developer/teacher)
  final int group;

  /// Map of blocks and course ids
  final List<Selection> selected;

  /// Map of subjects and writing option
  final List<Exam> exams;

  /// Cafetoria login data
  final CafetoriaTags cafetoriaLogin;

  // ignore: public_member_api_docs
  Tags({
    this.group,
    this.grade,
    this.selected,
    this.exams,
    this.cafetoriaLogin,
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
      exams: json['exams'].map<Exam>((json) => Exam.fromJson(json)).toList(),
      selected: json['selected'].map<Selection>((json) => Selection.fromJson(json)).toList(),
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
  final DeviceSettings deviceSettings;
  // ignore: public_member_api_docs
  final String firebaseId;

  // ignore: public_member_api_docs
  Device(
      {this.os,
      this.name,
      this.appVersion,
      this.deviceSettings,
      this.firebaseId});

  /// Creates a device from json map
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      os: json['os'] as String,
      name: json['name'] as String,
      appVersion: json['appVersion'] as String,
      deviceSettings: DeviceSettings.fromJson(json['settings']),
      firebaseId: json['firebaseId'] as String,
    );
  }

  /// Convert a device to a json map
  Map<String, dynamic> toMap() {
    return {
      'os': os,
      'name': name,
      'appVersion': appVersion,
      'firebaseId': firebaseId,
      'settings': deviceSettings.toMap(),
    };
  }
}

/// Describes all settings to sync for this device
class DeviceSettings {
  /// Getting substitution plan notifications
  final bool spNotifications;

  // ignore: public_member_api_docs
  const DeviceSettings({this.spNotifications});

  // ignore: public_member_api_docs
  factory DeviceSettings.fromJson(Map<String, dynamic> json) {
    return DeviceSettings(
      spNotifications: json['spNotifications'],
    );
  }

  /// Converts the device settings to a json map
  Map<String, dynamic> toMap() {
    return {'spNotifications': spNotifications};
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

/// Describes a user selection
class Selection {
  /// The block identifier
  final String block;

  /// The course identifier
  final String courseID;

  /// The last changed timestamp
  final DateTime timestamp;

  // ignore: public_member_api_docs
  const Selection({this.block, this.courseID, this.timestamp});

  // ignore: public_member_api_docs
  factory Selection.fromJson(Map<String, dynamic> json) {
    return Selection(
      block: json['block'] as String,
      courseID: json['courseID'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the device settings to a json map
  Map<String, dynamic> toMap() {
    return {
      'block': block,
      'courseID': courseID,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Describes all settings to sync for this device
class Exam {
  /// The subject identifier
  final String subject;

  /// The writing option
  final bool writing;

  /// The last changed timestamp
  final DateTime timestamp;

  // ignore: public_member_api_docs
  const Exam({this.subject, this.writing, this.timestamp});

  // ignore: public_member_api_docs
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      subject: json['subject'] as String,
      writing: json['writing'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the device settings to a json map
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'writing': writing,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}