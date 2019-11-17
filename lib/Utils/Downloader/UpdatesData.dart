import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart' as Network;
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class UpdatesData extends Downloader<Updates> {
  UpdatesData()
      : super(
          url: Network.Urls.updates,
          key: Keys.updates,
          defaultData: _defaultValue,
        );

  @override
  Future<int> download(BuildContext context, {bool update = true}) async {
    if (!update) {
      saveStatic(fetch());
      return Network.StatusCodes.success;
    }

    // Get response
    final response = await Network.fetch(Network.Urls.updates);
    int statusCode = response.statusCode;

    if (statusCode != Network.StatusCodes.success) {
      return statusCode;
    }

    // Parse data...
    saveStatic(parse(response.body));
    return statusCode;
  }

  /// Returns the static updates...
  Updates getUpdates({loaded = true}) {
    var savedUpdates = Storage.getString(Keys.updates);
    if (savedUpdates == null) savedUpdates = json.encode(defaultData);
    return loaded ? Data.updates : parse(savedUpdates);
  }

  @override
  Updates getData() {
    return Data.updates;
  }

  @override
  void saveStatic(Updates data) {
    Data.updates = data;
  }

  void saveUpdates() {
    Storage.setString(Keys.updates, Data.updates.toJson());
  }

  @override
  Updates parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return Updates.fromJson(parsed);
  }

  static get _defaultValue => Updates(
          timetable: DateTime.fromMillisecondsSinceEpoch(0),
          substitutionPlan: DateTime.fromMillisecondsSinceEpoch(0),
          cafetoria: DateTime.fromMillisecondsSinceEpoch(0),
          calendar: DateTime.fromMillisecondsSinceEpoch(0),
          teachers: DateTime.fromMillisecondsSinceEpoch(0),
          workgroups: DateTime.fromMillisecondsSinceEpoch(0),
          rooms: DateTime.fromMillisecondsSinceEpoch(0),
          subjects: DateTime.fromMillisecondsSinceEpoch(0),
          minAppLevel: 1,
          grade: '')
      .toMap();
}
