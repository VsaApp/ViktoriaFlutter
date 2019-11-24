import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:viktoriaflutter/Utils/Encrypt.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

import 'Keys.dart';
import 'Network.dart';
import 'Storage.dart';
import 'Times.dart';

/// Returns all saved tags from the server
Future<Tags> getTags() async {
  try {
    final Response response = await fetch(Urls.tags);
    if (response.statusCode != StatusCodes.success) {
      throw Exception('Failed to load tags');
    }
    final Tags tags = Tags.fromJson(json.decode(response.body));
    Data.tags = tags;
    return tags;
  } catch (_) {
    return null;
  }
}

/// Checks if the tags on the server are already initialized
Future<bool> isInitialized() async {
  final Tags tags = await getTags();
  return tags.isInitialized;
}

/// Synchronize local data with server tags
Future<bool> syncWithTags(
    {Tags tags, bool autoSync = true, bool forceSync = false}) async {
  tags ??= await getTags();
  if (tags != null) {
    // Sync grade
    Storage.setString(Keys.grade, tags.grade);

    // Check if the cafetoria data on the server is newer than the local
    bool cafetoriaIsNewer = false;
    if (tags.isInitialized) {
      final String cafetoriaModified = Storage.getString(Keys.cafetoriaModified);
      if (cafetoriaModified != null) {
        final DateTime local = DateTime.parse(cafetoriaModified);
        if (tags.cafetoriaLogin.timestamp.isAfter(local)) {
          cafetoriaIsNewer = true;
        }
      } else if (tags.cafetoriaLogin.id != null) {
        cafetoriaIsNewer = true;
      }
    }

    if (cafetoriaIsNewer) {
      if (tags.cafetoriaLogin.id == null) {
        Storage.remove(Keys.cafetoriaId, autoSet: true);
        Storage.remove(Keys.cafetoriaPassword, autoSet: true);
      } else {
        final String decryptedID = decryptText(tags.cafetoriaLogin.id);
        final String decryptedPassword = decryptText(tags.cafetoriaLogin.password);
        Storage.setString(Keys.cafetoriaId, decryptedID, autoSet: true);
        Storage.setString(Keys.cafetoriaPassword, decryptedPassword,
            autoSet: true);
      }
      Storage.setString(Keys.cafetoriaModified,
          tags.cafetoriaLogin.timestamp.toIso8601String());
    }

    // Check if the server hast newer data than the local data
    final String _lastModified = Storage.getString(Keys.lastModified);
    bool serverIsNewer = true;
    bool localIsNewer = false;

    // If the server do not has any data of this user, do not sync
    if (!tags.isInitialized) {
      serverIsNewer = false;
    }
    // If there are already local changes compare the newer version
    else if (_lastModified != null) {
      final DateTime lastModified = DateTime.parse(_lastModified);
      serverIsNewer = tags.timestamp.isAfter(lastModified);
      localIsNewer = lastModified.isAfter(tags.timestamp);
    }

    // If the server has newer data, sync phone
    if (serverIsNewer || forceSync) {
      print('Sync device with server');

      // Reset local selections
      Storage.getKeys()
          .where((key) => key.startsWith(Keys.selection('')))
          .forEach((key) => Storage.remove(key, autoSet: true));
      // Set all courses to non writing
      Storage.getKeys()
          .where((key) => key.startsWith(Keys.exams('')))
          .forEach((key) => Storage.setBool(key, false, autoSet: true));

      // Set new selections
      tags.selected.forEach((course) {
        Storage.setBool(Keys.selection(course), true, autoSet: true);
      });

      // Set new exam settings
      tags.exams.forEach((course) {
        Storage.setBool(Keys.exams(course), true, autoSet: true);
      });

      Storage.setString(Keys.lastModified, tags.timestamp.toIso8601String());
    } else if (localIsNewer && autoSync) {
      await syncTags(checkSync: false);
    }
    return serverIsNewer;
  }
  return false;
}

/// Initialize device tags
Future initTags(BuildContext context) async {
  if ((await checkOnline) == -1) {
    return;
  }
  final String id = await FirebaseMessaging().getToken();
  final String appVersion = (await rootBundle.loadString('pubspec.yaml'))
      .split('\n')
      .where((line) => line.startsWith('version'))
      .toList()[0]
      .split(':')[1]
      .trim();
  String os = '';
  String deviceName = '';
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    os = 'Android ${androidInfo.version.release}';
    deviceName = '${androidInfo.model} ${androidInfo.manufacturer}';
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    os = 'iOS ${iosInfo.systemVersion}';
    deviceName = iosInfo.utsname.machine;
  }
  final String language = AppLocalizations.of(context).locale.languageCode;
  final Device device = Device(
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

/// Send tags to server
Future sendTags(Map<String, dynamic> tags) async {
  try {
    await httpPost(Urls.tags, body: tags);
  } catch (_) {}
}

/// Delete tags from server
Future deleteTags(Map<String, dynamic> tags) async {
  final String url = Urls.tags;
  try {
    await httpDelete(url, body: tags);
  } catch (_) {}
}

/// Sync the length of each day
void syncDaysLength() {
  String lengths = '';
  Data.timetable.days.forEach((day) {
    final int count = day.getUserLessonsCount('Freistunde');
    // ignore: prefer_interpolation_to_compose_strings
    lengths += times[count].split(' - ')[1] + '|';
  });
  Storage.setString(Keys.daysLengths, lengths);
}

/// Sync the tags
Future syncTags(
    {bool syncExams = true,
    bool syncSelections = true,
    bool syncCafetoria = true,
    bool checkSync = true}) async {
  if ((await checkOnline) != 1) {
    return;
  }

  // Get all server tags...
  final Tags allTags = await getTags();
  if (allTags == null) {
    return;
  }

  if (checkSync) {
    final bool synced = await syncWithTags(tags: allTags, autoSync: false);
    if (synced) {
      return;
    }
  }

  // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
  Storage.setInt(Keys.group, allTags.group);

  // Compare new and old tags...
  final String lastModified = Storage.getString(Keys.lastModified);
  final Map<String, dynamic> tagsToRemove = {
    'timestamp': lastModified,
  };
  final Map<String, dynamic> tagsToUpdate = {
    'timestamp': lastModified,
  };

  if (syncExams || syncSelections) {
    // Get all selected subjects
    final List<TimetableSubject> subjects = Data.timetable
        .getAllSelectedSubjects()
        .where((TimetableSubject subject) {
          return subject.subjectID != 'Mittagspause';
        })
        .toSet()
        .toList();

    // Sync all selected exams
    final List<String> exams = subjects
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
    final List<String> selected =
        subjects.map((TimetableSubject subject) => subject.courseID).toList();

    tagsToUpdate['selected'] =
        selected.where((tag) => !allTags.selected.contains(tag)).toList();
    tagsToRemove['selected'] =
        allTags.selected.where((tag) => !selected.contains(tag)).toList();
  }

  if (syncCafetoria) {
    final String id = Storage.getString(Keys.cafetoriaId);
    final String password = Storage.getString(Keys.cafetoriaPassword);
    final String lastModified = Storage.getString(Keys.cafetoriaModified);

    if (id != null && password != null && lastModified != null) {
      final encryptedId = encryptText(id);
      final encryptedPassword = encryptText(password);

      if (allTags.cafetoriaLogin.id == null ||
          (allTags.cafetoriaLogin.id != encryptedId &&
              allTags.cafetoriaLogin.password != encryptedPassword)) {
        tagsToUpdate['cafetoria'] = CafetoriaTags(
                id: encryptedId,
                password: encryptedPassword,
                timestamp: DateTime.parse(lastModified))
            .toMap();
      }
    } else if (lastModified != null) {
      if (allTags.cafetoriaLogin.timestamp
          .isBefore(DateTime.parse(lastModified))) {
        tagsToRemove['cafetoria'] = CafetoriaTags(
                id: '', password: '', timestamp: DateTime.parse(lastModified))
            .toMap();
      }
    }
  }

  if ((tagsToRemove['selected'] != null &&
          tagsToRemove['selected'].length > 0) ||
      (tagsToRemove['exams'] != null && tagsToRemove['exams'].length > 0) ||
      tagsToRemove['cafetoria'] != null) {
    await deleteTags(tagsToRemove);
  }
  if ((tagsToUpdate['selected'] != null &&
          tagsToUpdate['selected'].length > 0) ||
      (tagsToUpdate['exams'] != null && tagsToUpdate['exams'].length > 0) ||
      tagsToUpdate['device'] != null ||
      tagsToUpdate['cafetoria'] != null) {
    await sendTags(tagsToUpdate);
  }
}
