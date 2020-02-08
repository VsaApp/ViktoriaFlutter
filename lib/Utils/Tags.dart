import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:viktoriaflutter/Utils/Encrypt.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

import 'Keys.dart';
import 'Network.dart';
import 'Storage.dart';

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
Future<void> syncWithTags(
    {Tags tags, bool autoSync = true, bool forceSync = false}) async {
  tags ??= await getTags();
  if (tags != null) {
    // Sync grade
    Storage.setString(Keys.grade, tags.grade);

    // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
    Storage.setInt(Keys.group, tags.group);

    // Check if the cafetoria data on the server is newer than the local
    bool cafetoriaIsNewer = false;
    if (tags.isInitialized) {
      final String cafetoriaModified =
          Storage.getString(Keys.cafetoriaModified);
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
        Storage.remove(Keys.cafetoriaId);
        Storage.remove(Keys.cafetoriaPassword);
      } else {
        final String decryptedID = decryptText(tags.cafetoriaLogin.id);
        final String decryptedPassword =
            decryptText(tags.cafetoriaLogin.password);
        Storage.setString(Keys.cafetoriaId, decryptedID);
        Storage.setString(Keys.cafetoriaPassword, decryptedPassword);
      }
      Storage.setString(Keys.cafetoriaModified,
          tags.cafetoriaLogin.timestamp.toIso8601String());
    }

    // If the server do not has any data of this user, do not sync
    if (tags.isInitialized) {
      // Sync selections
      tags.selected.forEach((selection) {
        final String selectedCourseId =
            Storage.getString(Keys.selection(selection.block));
        // If the course id changed, check wich version is newer
        if (selectedCourseId != selection.courseID) {
          final String selectedTimestamp =
              Storage.getString(Keys.selectionTimestamp(selection.block));
          // If the server is newer, sync the new course id
          if (selectedCourseId == null ||
              selection.timestamp.isAfter(DateTime.parse(selectedTimestamp))) {
            Storage.setString(
                Keys.selection(selection.block), selection.courseID);
            Storage.setString(Keys.selectionTimestamp(selection.block),
                selection.timestamp.toIso8601String());
          }
        }
      });

      // Sync exams
      tags.exams.forEach((exam) {
        final bool writing = Storage.getBool(Keys.exams(exam.subject));
        // If the course id changed, check wich version is newer
        if (writing != exam.writing) {
          final String examTimestamp =
              Storage.getString(Keys.examTimestamp(exam.subject));
          // If the server is newer, sync the new course id
          if (writing == null ||
              exam.timestamp.isAfter(DateTime.parse(examTimestamp))) {
            Storage.setBool(Keys.exams(exam.subject), exam.writing);
            Storage.setString(Keys.examTimestamp(exam.subject),
                exam.timestamp.toIso8601String());
          }
        }
      });
    } else if (autoSync) {
      await syncTags(checkSync: false);
    }
  }
  return;
}

/// Initialize device tags
Future initTags() async {
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
  final Device device = Device(
      firebaseId: id,
      appVersion: appVersion.isEmpty ? null : appVersion,
      name: deviceName.isEmpty ? null : deviceName,
      os: os.isEmpty ? null : os,
      deviceSettings: DeviceSettings(
        spNotifications:
            Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true,
      ));
  await sendTags({'device': device.toMap()});
}

/// Send tags to server
Future sendTags(Map<String, dynamic> tags) async {
  try {
    await httpPost(Urls.tags, body: tags);
  } catch (_) {}
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
    await syncWithTags(tags: allTags, autoSync: false);
  }

  // Get all changed tags
  final Map<String, dynamic> tagsToUpdate = {};

  if (syncExams || syncSelections) {
    final List<String> keys = Storage.getKeys();
    final List<Selection> selections = [];
    final List<Exam> exams = [];

    // Get all selections and exams
    keys.forEach((key) {
      // If the preference key is a selection
      if (key.startsWith(Keys.selection(''))) {
        final selection = Selection(
          block: key.split('-').sublist(1).join('-'),
          courseID: Storage.getString(key),
          timestamp: DateTime.parse(Storage.getString('timestamp-$key') ?? '20000101'),
        );
        // Check if the local selection is newer than the server selection
        final serverSelection =
            allTags.selected.where((s) => s.block == selection.block).toList();
        // If the server does not have this selection,
        // or the selection changed and the local version is newer, sync the selection
        if (serverSelection.isEmpty ||
            (serverSelection[0].courseID != selection.courseID &&
                selection.timestamp.isAfter(serverSelection[0].timestamp))) {
          selections.add(selection);
        }
      }
      // If the preference key is an exam
      else if (key.startsWith(Keys.exams(''))) {
        final exam = Exam(
            subject: key.split('-').sublist(1).join('-'),
            writing: Storage.getBool(key),
            timestamp: DateTime.parse(Storage.getString('timestamp-$key') ?? '20000101'));
        // Check if the local exam is newer than the server exam
        final serverExam =
            allTags.exams.where((e) => e.subject == exam.subject).toList();
        // If the server does not have this exam,
        // or the exam changed and the local version is newer, sync the exam
        if (serverExam.isEmpty ||
            (serverExam[0].writing != exam.writing &&
                exam.timestamp.isAfter(serverExam[0].timestamp))) {
          exams.add(exam);
        }
      }
    });

    tagsToUpdate['selected'] = selections.map((s) => s.toMap()).toList();
    tagsToUpdate['exams'] = exams.map((e) => e.toMap()).toList();
  }

  if (syncCafetoria) {
    final String id = Storage.getString(Keys.cafetoriaId);
    final String password = Storage.getString(Keys.cafetoriaPassword);
    final String lastModified = Storage.getString(Keys.cafetoriaModified);

    // If the local cafetoria login data is set and newer than the server login data
    if (lastModified != null &&
        DateTime.parse(lastModified)
            .isAfter(allTags.cafetoriaLogin.timestamp)) {
      final encryptedId = id == null ? null : encryptText(id);
      final encryptedPassword = password == null ? null : encryptText(password);

      if (allTags.cafetoriaLogin.id != encryptedId ||
          allTags.cafetoriaLogin.password != encryptedPassword) {
        tagsToUpdate['cafetoria'] = CafetoriaTags(
                id: encryptedId,
                password: encryptedPassword,
                timestamp: DateTime.parse(lastModified))
            .toMap();
      }
    }
  }

  if ((tagsToUpdate['selected'] != null &&
          tagsToUpdate['selected'].length > 0) ||
      (tagsToUpdate['exams'] != null && tagsToUpdate['exams'].length > 0) ||
      tagsToUpdate['device'] != null ||
      tagsToUpdate['cafetoria'] != null) {
    await sendTags(tagsToUpdate);
  }
}
