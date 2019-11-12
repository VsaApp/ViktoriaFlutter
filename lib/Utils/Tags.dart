import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

import 'Times.dart';
import 'Keys.dart';
import 'Network.dart';
import 'Storage.dart';
import '../Timetable/TimetableData.dart';

Future<Map<String, dynamic>> getTags() async {
  try {
    return json.decode(await fetchData(Urls.tags));
  } on Exception catch (_) {
    return null;
  }
}

Future sendTag(String key, dynamic value) async {
  sendTags({key: value});
}

Future<Map<String, dynamic>> isInitialized() async {
  Map<String, dynamic> tags = await getTags();
  if (tags.keys.length > 0) return tags;
  return null;
}

Future syncWithTags({Map<String, dynamic> tags}) async {
  if (tags == null) tags = await getTags();
  if (tags != null) {
    // Check if the server hast newer data than the local data
    String _lastModified = Storage.getString(Keys.lastModified);
    String _timestamp = tags['timestamp'];
    bool serverIsNewer = true;
    if (_lastModified != null && _timestamp != null) {
      DateTime lastModified = DateTime.parse(_lastModified);
      DateTime timestamp = DateTime.parse(_timestamp);
      serverIsNewer = timestamp.isAfter(lastModified);
    } else if (_timestamp == null) {
      serverIsNewer = false;
    }

    // If the server has newer data, sync phone
    if (serverIsNewer) {
      if (tags['selected'] != null) {
        // Reset local selections
        Storage.getKeys()
            .where((key) => key.startsWith(Keys.selection('')))
            .forEach((key) => Storage.remove(key));
        // Set new selections
        tags['selected'].forEach((key) {
          Storage.setBool(Keys.selection(key['courseID'] as String), true);
        });
      }
      if (tags['exams'] != null) {
        // Reset local exam settings
        Storage.getKeys()
            .where((key) => key.startsWith(Keys.exams('')))
            .forEach((key) => Storage.remove(key));
        // Set new exam settings
        tags['exams'].forEach((key) {
          Storage.setBool(Keys.exams(key['courseID'] as String), true);
        });
      }
    }
  }
}

Future initTags(BuildContext context, String id) async {
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
  String language = AppLocalizations.of(context).locale.languageCode;
  Map<String, dynamic> send = {
    'device': {
      'firebaseId': id,
      'language': language,
      'notifications':
          Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true
    },
  };
  if (appVersion != '') {
    send['device']['appVersion'] = appVersion;
  }
  if (deviceName != '') {
    send['device']['name'] = deviceName;
  }
  if (os != '') {
    send['device']['os'] = os;
  }
  await sendTags(send);
}

Future sendTags(Map<String, dynamic> tags) async {
  try {
    await httpPost(Urls.tags, body: tags);
  } catch (_) {}
}

Future deleteTags(Map<String, dynamic> tags) async {
  String url = Urls.tags;
  try {
    httpDelete(url, body: tags);
  } catch (_) {}
}

void syncDaysLength() {
  String lengths = '';
  getTimetable().forEach((day) {
    int count = day.getUserLessonsCount('Freistunde');
    lengths += times[count].split(' - ')[1] + '|';
  });
  Storage.setString(Keys.daysLengths, lengths);
}

// Sync the tags...
Future syncTags() async {
  if ((await checkOnline) == -1) return;
  syncDaysLength();

  // Get all timetable and exams tags...
  Map<String, dynamic> allTags = await getTags();
  if (allTags == null) return;

  if (Storage.getString(Keys.lastModified) == null) {
    await syncTags();
  }
  else if (DateTime.parse(allTags['timestamp'])
      .isAfter(DateTime.parse(Storage.getString(Keys.lastModified)))) {
    await syncWithTags(tags: allTags);
    return;
  }

  // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
  Storage.setInt(Keys.group, allTags['group'] as int);

  // Get all selected subjects...
  List<TimetableSubject> subjects = Data.timetable
      .getAllSelectedSubjects()
      .where((TimetableSubject subject) {
        return subject.subjectID != 'Mittagspause' &&
            subject.subjectID != 'Freistunde';
      })
      .toSet()
      .toList();

  List<String> exams = subjects
      .where((TimetableSubject subject) =>
          Storage.getBool(Keys.exams(subject.courseID)) ?? true)
      .map((TimetableSubject subject) => subject.courseID)
      .toList();

  List<String> selected =
      subjects.map((TimetableSubject subject) => subject.courseID).toList();

  bool notifications =
      Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true;

  // Compare new and old tags...
  Map<String, dynamic> tagsToUpdate = {
    if (allTags['device']['notifications'] != notifications)
      'device': {
        'notifications': notifications,
      },
    'exams': exams.where((tag) => !allTags['exams'].contains(tag)),
    'selected': selected.where((tag) => !allTags['selected'].contains(tag)),
  };
  Map<String, dynamic> tagsToRemove = {
    'selected': allTags['selected'].where((tag) => !selected.contains(tag)),
    'exams': allTags['exams'].where((tag) => !exams.contains(tag)),
  };
  if (tagsToRemove['selected'].length > 0 || tagsToRemove['exams'].length > 0)
    await deleteTags(tagsToRemove);
  if (tagsToUpdate['selected'].length > 0 || tagsToUpdate['exams'].length > 0)
    await sendTags(tagsToUpdate);
}
