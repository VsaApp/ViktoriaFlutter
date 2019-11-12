import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Download work groups data...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    await fetchDataAndSave(Urls.workgroups, Keys.workGroups, '[]', onFinished: (v) => successfully = v == 200);
  }

  // Parse loaded data...
  Data.workGroups = fetchGroups();
  if (onFinished != null) onFinished(successfully);
}

/// Returns the static work groups data...
List<WorkGroupsDay> getWorkGroups() {
  return Data.workGroups.days;
}

/// Load work groups from preferences...
WorkGroups fetchGroups() {
  return parseGroups(Storage.getString(Keys.workGroups));
}

/// Returns parse work groups days...
WorkGroups parseGroups(String responseBody) {
  final parsed = json.decode(responseBody);
  return WorkGroups(days: parsed
      .map<WorkGroupsDay>((json) => WorkGroupsDay.fromJson(json))
      .toList());
}
