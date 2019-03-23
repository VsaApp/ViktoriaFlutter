import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:onesignal/onesignal.dart';

import 'Id.dart';
import 'Keys.dart';
import 'Messageboard/MessageboardModel.dart';
import 'Network.dart';
import 'Selection.dart';
import 'Storage.dart';
import 'UnitPlan/UnitPlanData.dart';

Future<Map<String, dynamic>> getTags({String idToLoad}) async {
  String id = idToLoad ?? Id.id;
  String url = 'https://api.vsa.2bad2c0.de/tags/$id';
  try {
    return json.decode((await http.Client().get(url).timeout(maxTime)).body);
  } on Exception catch (e) {
    print('Error during getting tags: ${e.toString()}');
    return null;
  }
}

Future sendTag(String key, dynamic value) async {
  sendTags({key: value});
}

Future<Map<String, dynamic>> isInitialized() async {
  Map<String, dynamic> deviceId = await getTags(idToLoad: await Id.id);
  if (deviceId.keys.length > 0) return deviceId;
  return null;
}

Future syncWithTags() async {
  Map<String, dynamic> tags = await getTags();
  tags.forEach((key, value) {
    key = key.toString();
    print(key);
    if (key.contains('unitPlan')) {
      Storage.setStringList(key, value == null ? null : value.cast<String>());
    } else if (key.contains('exam')) {
      Storage.setBool(
          Keys.exams(key.split('-')[1], key.split('-')[2].toUpperCase()),
          value);
    } else if (key == 'dev') {
      Storage.setBool(key, value);
    } else if (key.contains('room')) {
      print(key);
      print(value);
      Storage.setString(key, value);
    }
  });
}

Future initTags() async {
  if ((await checkOnline) == -1) return;
  sendTags({
    Keys.grade: Storage.getString(Keys.grade),
    Keys.dev: Storage.getBool(Keys.dev) ?? false
  });
}

Future sendTags(Map<String, dynamic> tags) async {
  String id = Id.id;
  await post('https://api.vsa.2bad2c0.de/tags/$id/add', body: tags);
}

Future deleteTag(String key) async {
  deleteTags([key]);
}

Future deleteTags(List<String> tags) async {
  String id = Id.id;
  String url = 'https://api.vsa.2bad2c0.de/tags/$id/remove';
  post(url, body: tags);
}

Future deleteOldTags() async {
  Map<String, dynamic> tags = await getTags();
  if (tags == null) return;
  List<String> tagsToDelete = [];
  tags.forEach((tag, value) {
    if (!(tag.startsWith('messageboard') ||
        tag.startsWith('unitPlan') ||
        tag.startsWith('dev') ||
        tag.startsWith('grade') ||
        tag.startsWith('exam'))) {
      tagsToDelete.add(tag);
    }
  });
  if (tagsToDelete.length > 0) deleteTags(tagsToDelete);
}

Future getPlayerId() async {
  return (await OneSignal.shared.getPermissionSubscriptionState())
      .subscriptionStatus
      .userId;
}

// Sync the onesignal tags...
Future syncTags() async {
  if ((await checkOnline) == -1) return;

  String grade = Storage.getString(Keys.grade);

  // Get all unitplan and exams tags...
  Map<String, dynamic> allTags = await getTags();
  if (allTags == null) return;
  allTags.removeWhere((key, value) =>
  !key.startsWith('unitPlan') &&
      !key.startsWith('exams') &&
      !key.startsWith('room'));

  // Get all selected subjects...
  List<String> subjects = [];
  getUnitPlan().forEach((day) {
    day.lessons.forEach((lesson) {
      int selected = getSelectedIndex(lesson.subjects,
          getUnitPlan().indexOf(day), day.lessons.indexOf(lesson));
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

  // Only set tags when the user activated notifications...
  if (Storage.getBool(Keys.getReplacementPlanNotifications) ?? true) {
    // Set all new unitplan tags...
    getUnitPlan().forEach((day) {
      day.lessons.forEach((lesson) {
        newTags[Keys.unitPlan(grade,
            block: lesson.subjects[0].block,
            day: getUnitPlan().indexOf(day),
            unit: day.lessons.indexOf(lesson))] =
            Storage.getStringList(Keys.unitPlan(grade,
                block: lesson.subjects[0].block,
                day: getUnitPlan().indexOf(day),
                unit: day.lessons.indexOf(lesson)));
      });
    });
  }

  Storage.getKeys().where((key) => key.startsWith('room-')).forEach((key) {
    newTags[key] = Storage.getString(key);
  });

  // Add all messageboard tags...
  List<Group> notifications = Messageboard.notifications;
  Messageboard.following.forEach((group) =>
  newTags[Keys.messageboardGroupTag(group.name)] =
      notifications.contains(group));

  if (Platform.isIOS || Platform.isAndroid) {
    // Add current OneSignal id...
    newTags['onesignalId'] = await getPlayerId();
  }
  // Compare new and old tags...
  Map<String, dynamic> tagsToUpdate = {};
  Map<String, dynamic> tagsToRemove = {};

  // Get all removed and changed tags...
  allTags.forEach((key, value) {
    if (!newTags.containsKey(key))
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
