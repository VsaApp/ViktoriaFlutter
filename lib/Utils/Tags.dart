import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

import 'Times.dart';
import 'Keys.dart';
import 'Network.dart';
import 'Storage.dart';
import '../Timetable/TimetableData.dart';

Future<Tags> getTags() async {
  try {
    Response response = await fetch(Urls.tags);
    assert(response.statusCode == StatusCodes.success);
    Tags tags = Tags.fromJson(json.decode(response.body));
    Data.tags = tags;
    return tags;
  } on Exception catch (_) {
    return null;
  }
}

Future<bool> isInitialized() async {
  Tags tags = await getTags();
  return tags.isInitialized;
}

Future<bool> syncWithTags(
    {Tags tags, bool autoSync = true, bool forceSync = false}) async {
  if (tags == null) tags = await getTags();
  if (tags != null) {
    // Sync grade
    Storage.setString(Keys.grade, tags.grade);

    // Check if the server hast newer data than the local data
    String _lastModified = Storage.getString(Keys.lastModified);
    bool serverIsNewer = true;
    bool localIsNewer = false;

    // If the server do not has any data of this user, do not sync
    if (!tags.isInitialized) {
      serverIsNewer = false;
    }
    // If there are already local changes compare the newer version
    else if (_lastModified != null) {
      DateTime lastModified = DateTime.parse(_lastModified);
      serverIsNewer = tags.timestamp.isAfter(lastModified);
      localIsNewer = lastModified.isAfter(tags.timestamp);
    }

    // If the server has newer data, sync phone
    if (serverIsNewer || forceSync) {
      print('Sync device with server');

      // Reset local selections
      Storage.getKeys()
          .where((key) => key.startsWith(Keys.selection('')))
          .forEach((key) => Storage.remove(key));
      // Set all courses to non writing
      Storage.getKeys()
          .where((key) => key.startsWith(Keys.exams('')))
          .forEach((key) => Storage.setBool(key, false));

      // Set new selections
      tags.selected.forEach((course) {
        Storage.setBool(Keys.selection(course), true);
      });

      // Set new exam settings
      tags.exams.forEach((course) {
        Storage.setBool(Keys.exams(course), true);
      });

      Storage.setString(Keys.lastModified, tags.timestamp.toIso8601String());
    } else if (localIsNewer && autoSync) await syncTags(checkSync: false);
    return serverIsNewer;
  }
  return false;
}

Future initTags(BuildContext context) async {
  if ((await checkOnline) == -1) return;
  String id = await FirebaseMessaging().getToken();
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
  Device device = Device(
      language: language,
      firebaseId: id,
      notifications:
          Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true,
      appVersion: appVersion.isEmpty ? null : appVersion,
      name: deviceName.isEmpty ? null : deviceName,
      os: os.isEmpty ? null : os);
  await sendTags({
    'device': device.toMap(),
    'timestamp': DateTime.now().toIso8601String()
  });
}

Future sendTags(Map<String, dynamic> tags) async {
  try {
    await httpPost(Urls.tags, body: tags);
  } catch (_) {}
}

Future deleteTags(Map<String, dynamic> tags) async {
  String url = Urls.tags;
  try {
    await httpDelete(url, body: tags);
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
Future syncTags(
    {bool syncExams = true,
    bool syncSelections = true,
    bool checkSync = true}) async {
  if ((await checkOnline) != 1) return;

  // Get all server tags...
  Tags allTags = await getTags();
  if (allTags == null) return;

  if (checkSync) {
    bool synced = await syncWithTags(tags: allTags, autoSync: false);
    if (synced) return;
  }

  // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
  Storage.setInt(Keys.group, allTags.group);

  // Compare new and old tags...
  String lastModified = Storage.getString(Keys.lastModified);
  Map<String, dynamic> tagsToRemove = {
    'timestamp': lastModified,
  };
  Map<String, dynamic> tagsToUpdate = {
    'timestamp': lastModified,
  };

  if (syncExams || syncSelections) {
    // Get all selected subjects
    List<TimetableSubject> subjects = Data.timetable
        .getAllSelectedSubjects()
        .where((TimetableSubject subject) {
          return subject.subjectID != 'Mittagspause' &&
              subject.subjectID != 'Freistunde';
        })
        .toSet()
        .toList();

    // Sync all selected exams
    List<String> exams = subjects
        .where((TimetableSubject subject) => subject.writeExams)
        .map((TimetableSubject subject) => subject.courseID)
        .toSet()
        .toList();

    tagsToUpdate['exams'] =
        exams.where((tag) => !allTags.exams.contains(tag)).toList();
    tagsToRemove['exams'] =
        allTags.exams.where((tag) => !exams.contains(tag)).toList();

    // Sync all selected subjects
    syncDaysLength();
    List<String> selected =
        subjects.map((TimetableSubject subject) => subject.courseID).toList();

    tagsToUpdate['selected'] =
        selected.where((tag) => !allTags.selected.contains(tag)).toList();
    tagsToRemove['selected'] =
        allTags.selected.where((tag) => !selected.contains(tag)).toList();
  }

  if ((tagsToRemove['selected'] != null &&
          tagsToRemove['selected'].length > 0) ||
      (tagsToRemove['exams'] != null && tagsToRemove['exams'].length > 0)) {
    await deleteTags(tagsToRemove);
  }
  if ((tagsToUpdate['selected'] != null &&
          tagsToUpdate['selected'].length > 0) ||
      (tagsToUpdate['exams'] != null && tagsToUpdate['exams'].length > 0) ||
      tagsToUpdate['device'] != null) {
    await sendTags(tagsToUpdate);
  }
}
