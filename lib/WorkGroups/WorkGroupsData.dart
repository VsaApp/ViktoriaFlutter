import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'WorkGroupsModel.dart';

// Download work groups data...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = '/workgroups/workgroups.json?v=' + Random().nextInt(99999999).toString();
    await fetchDataAndSave(url, Keys.workGroups, '[]', onFinished: (v) => successfully = v);
  }

  // Parse loaded data...
  WorkGroups.days = await fetchGroups();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static work groups data...
List<WorkGroupsDay> getWorkGroups() {
  return WorkGroups.days;
}

// Load work groups from preferences...
Future<List<WorkGroupsDay>> fetchGroups() async {
  return parseGroups(Storage.getString(Keys.workGroups));
}

// Returns parse work groups days...
List<WorkGroupsDay> parseGroups(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed
      .map<WorkGroupsDay>((json) => WorkGroupsDay.fromJson(json))
      .toList();
}
