import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'Times.dart';
import 'Id.dart';
import 'Keys.dart';
import 'Network.dart';
import 'Selection.dart';
import 'Storage.dart';
import '../Timetable/TimetableData.dart';

Future<Map<String, dynamic>> getTags({String idToLoad}) async {
  String id = idToLoad ?? Id.id;
  String url = '/tags/$id';
  try {
    return json.decode(await fetchData(url));
  } on Exception catch (_) {
    return null;
  }
}

Future sendTag(String key, dynamic value) async {
  sendTags({key: value});
}

Future<Map<String, dynamic>> isInitialized() async {
  Map<String, dynamic> deviceId = await getTags(idToLoad: Id.id);
  if (deviceId.keys.length > 0) return deviceId;
  return null;
}

Future syncWithTags() async {
  Map<String, dynamic> tags = await getTags();
  if (tags != null) {
    tags.forEach((key, value) {
      key = key.toString();
      if (key.contains('timetable')) {
        Storage.setStringList(key, value == null ? null : value.cast<String>());
      } else if (key.contains('exam')) {
        Storage.setBool(
            Keys.exams(key.split('-')[1], key.split('-')[2].toUpperCase()),
            value);
      } else if (key == 'dev') {
        Storage.setBool(key, value);
      } else if (key.contains('room')) {
        Storage.setString(key, value);
      }
    });
  }
}

Future initTags(id) async {
  if ((await checkOnline) == -1) return;
  String appVersion = (await rootBundle.loadString('pubspec.yaml'))
      .split('\n')
      .where((line) => line.startsWith('version'))
      .toList()[0]
      .split(':')[1]
      .trim();
  String os = '';
  String deviceName = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    os = 'Android ' + androidInfo.version.release;
    deviceName = androidInfo.model + ' ' + androidInfo.manufacturer;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    os = 'iOS ' + iosInfo.systemVersion;
    deviceName = iosInfo.utsname.machine;
  }
  Map<String, dynamic> send = {
    Keys.grade: Storage.getString(Keys.grade),
    Keys.dev: Storage.getBool(Keys.dev) ?? false,
    'firebaseId': id,
    'lastSession': DateTime.now().toIso8601String(),
  };
  if (appVersion != '') {
    send['appVersion'] = appVersion;
  }
  if (deviceName != '') {
    send['deviceName'] = deviceName;
  }
  if (os != '') {
    send['os'] = os;
  }
  sendTags(send);
}

Future sendTags(Map<String, dynamic> tags) async {
  String id = Id.id;
  try {
    await post('/tags/$id/add', body: tags);
  } catch (_) {}
}

Future deleteTag(String key) async {
  deleteTags([key]);
}

Future deleteTags(List<String> tags) async {
  String id = Id.id;
  String url = '/tags/$id/remove';
  try {
    post(url, body: tags);
  } catch (_) {}
}

void syncDaysLength() {
  String lengths = '';
  getTimetable().forEach((day) {
    int count = day.getUserLesseonsCount('Freistunde');
    lengths += times[count].split(' - ')[1] + '|';
  });
  Storage.setString(Keys.daysLengths, lengths);
}

// Sync the tags...
Future syncTags() async {
  if ((await checkOnline) == -1) return;
  syncDaysLength();
  String grade = Storage.getString(Keys.grade);

  // Get all timetable and exams tags...
  Map<String, dynamic> allTags = await getTags();
  if (allTags == null) return;
  allTags.removeWhere((key, value) =>
  !key.startsWith('timetable') &&
      !key.startsWith('exams') &&
      !key.startsWith('room'));

  // Get all selected subjects...
  List<String> subjects = [];
  getTimetable().forEach((day) {
    day.lessons.forEach((lesson) {
      int selected = getSelectedIndex(lesson.subjects,
          getTimetable().indexOf(day), day.lessons.indexOf(lesson));
      if (selected == null) {
        return;
      }
      subjects.add(lesson.subjects[selected].lesson);
    });
  });

  // Remove all lunch times...
  subjects = subjects.where((subject) {
    return subject != 'Mittagspause' && subject != 'Freistunde';
  }).toList();

  // Remove double subjects...
  subjects = subjects.toSet().toList();

  // Get all new exams tags...
  Map<String, dynamic> newTags = {};
  subjects.forEach((subject) =>
  newTags[Keys.exams(grade, subject)] =
      Storage.getBool(Keys.exams(grade, subject.toUpperCase())) ?? true);

  newTags[Keys.getSubstitutionPlanNotifications] = Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true;

  // Set all new timetable tags...
  getTimetable().forEach((day) {
    day.lessons.forEach((lesson) {
      newTags[Keys.timetable(grade,
          block: lesson.subjects[0].block,
          day: getTimetable().indexOf(day),
          unit: day.lessons.indexOf(lesson))] =
          Storage.getStringList(Keys.timetable(grade,
              block: lesson.subjects[0].block,
              day: getTimetable().indexOf(day),
              unit: day.lessons.indexOf(lesson)));
    });
  });

  Storage.getKeys().where((key) => key.startsWith('room-')).forEach((key) {
    newTags[key] = Storage.getString(key);
  });

  // Compare new and old tags...
  Map<String, dynamic> tagsToUpdate = {};
  Map<String, dynamic> tagsToRemove = {};

  // Get all removed and changed tags...
  allTags.forEach((key, value) {
    if (!newTags.containsKey(key) && key != 'firebaseId')
      tagsToRemove[key] = value;
    else if (value.toString() != newTags[key].toString()) {
      tagsToUpdate[key] = newTags[key];
    }
  });
  // Get all new tags...
  newTags.keys
      .where((key) => !allTags.containsKey(key))
      .forEach((key) => tagsToUpdate[key] = newTags[key]);

  if (tagsToRemove.length > 0) await deleteTags(tagsToRemove.keys.toList());
  if (tagsToUpdate.length > 0) await sendTags(tagsToUpdate);
}
