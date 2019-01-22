import 'dart:convert';

import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Network.dart';
import 'Keys.dart';
import 'UnitPlan/UnitPlanData.dart';
import 'Messageboard/MessageboardModel.dart';

Future<Map<String, dynamic>> getTags() async {
  String id = await getPlayerId();
  String url = 'https://api.vsa.2bad2c0.de/tags/$id';
  return json.decode((await http.Client().get(url).timeout(maxTime)).body);
}

Future sendTag(String key, dynamic value) async {
  sendTags({key: value});
}

Future initTags() async {
  if ((await checkOnline) == -1) return;
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sendTags({Keys.grade: sharedPreferences.getString(Keys.grade), Keys.dev: sharedPreferences.getBool(Keys.dev) ?? false});
}

Future sendTags(Map<String, dynamic> tags) async {
  String id = await getPlayerId();
  await post('https://api.vsa.2bad2c0.de/tags/$id/add', body: tags);
}

Future deleteTag(String key) async {
  deleteTags([key]);
}

Future deleteTags(List<String> tags) async {
  String id = await getPlayerId();
  String url = 'https://api.vsa.2bad2c0.de/tags/$id/remove';
  post(url, body: tags);
}

Future deleteOldTags() async {
  Map<String, dynamic> tags = await getTags();
  List<String> tagsToDelete = [];
  tags.forEach((tag, value) {
    if (!(tag.startsWith('messageboard') || tag.startsWith('unitplan') || tag.startsWith('dev') || tag.startsWith('grade') || tag.startsWith('exam'))) {
      tagsToDelete.add(tag);
    }
  });
  if (tagsToDelete.length > 0) deleteTags(tagsToDelete);
}

Future getPlayerId() async {
  return (await OneSignal.shared.getPermissionSubscriptionState()).subscriptionStatus.userId;
}
 
// Sync the onesignal tags...
Future syncTags() async {
  if ((await checkOnline) == -1) return;

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String grade = sharedPreferences.getString(Keys.grade);

  // Get all unitplan and exams tags...
  Map<String, dynamic> allTags = await getTags();
  allTags.removeWhere((key, value) => !key.startsWith('unitPlan') && !key.startsWith('exams'));

  // Get all selected subjects...
  List<String> subjects = [];
  getUnitPlan().forEach((day) {
    day.lessons.forEach((lesson) {
      int selected = sharedPreferences.getInt(Keys.unitPlan(grade,
          block: lesson.subjects[0].block,
          day: getUnitPlan().indexOf(day),
          unit: day.lessons.indexOf(lesson)));
      if (selected == null) {
        return;
      }
      subjects.add(lesson.subjects[selected].lesson);
    });
  });

  // Remove all lunch times...
  subjects = subjects.where((subject) {
    return subject.length < 3;
  }).toList();

  // Remove double subjects...
  subjects = subjects.toSet().toList();

  // Get all new exams tags...
  Map<String, dynamic> newTags = {};
  subjects.forEach((subject) => newTags[Keys.exams(grade, subject)] = sharedPreferences.getBool(Keys.exams(grade, subject)) ?? true);
  
  // Only set tags when the user activated notifications...
  if (sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
      true) {

    // Set all new unitplan tags...
    getUnitPlan().forEach((day) {
      day.lessons.forEach((lesson) {
        newTags[Keys.unitPlan(grade,
                block: lesson.subjects[0].block,
                day: getUnitPlan().indexOf(day),
                unit: day.lessons.indexOf(lesson))] = sharedPreferences.getInt(Keys.unitPlan(grade,
                    block: lesson.subjects[0].block,
                    day: getUnitPlan().indexOf(day),
                    unit: day.lessons.indexOf(lesson)))
                .toString();
      });
    });
  }

  // Add all messageboard tags...
  List<Group> notifications = Messageboard.notifications;
  Messageboard.following.forEach((group) => newTags[Keys.messageboardGroupTag(group.name)] = notifications.contains(group));

  // Compare new and old tags...
  Map<String, dynamic> tagsToUpdate = {};
  List<String> tagsToRemove = [];
  
  // Get all removed and changed tags...
  allTags.forEach((key, value) {
    if (!newTags.containsKey(key)) tagsToRemove.add(value);
    else if (value.toString() != newTags[key].toString()) {
      tagsToUpdate[key] = newTags[key];
    }
  });
  // Get all new tags...
  newTags.keys.where((key) => !allTags.containsKey(key)).forEach((key) => tagsToUpdate[key] = newTags[key]);

  if (tagsToRemove.length > 0) await deleteTags(tagsToRemove);
  if (tagsToUpdate.length > 0) await sendTags(tagsToUpdate);
}
