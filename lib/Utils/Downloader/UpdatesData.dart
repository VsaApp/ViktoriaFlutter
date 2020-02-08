import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart' as network;
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Updates data downloader
class UpdatesData extends Downloader<Updates> {
  // ignore: public_member_api_docs
  UpdatesData()
      : super(
          url: network.Urls.updates,
          key: Keys.updates,
          defaultData: _defaultValue,
        );

  @override
  Future<int> download(BuildContext context,
      {bool update = true, Map<String, dynamic> body}) async {
    if (!update) {
      saveStatic(fetch());
      return network.StatusCodes.success;
    }

    // Get response
    final response = await network.fetch(network.Urls.updates);
    final int statusCode = response.statusCode;

    if (statusCode != network.StatusCodes.success) {
      return statusCode;
    }

    // Parse data...
    saveStatic(parse(response.body ?? json.encode(defaultData)));
    return statusCode;
  }

  /// Returns the static updates...
  Updates getUpdates({bool loaded = true}) {
    var savedUpdates = Storage.getString(Keys.updates);
    savedUpdates ??= json.encode(defaultData);
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

  /// Saves updates in preferences
  void saveUpdates() {
    Storage.setString(Keys.updates, Data.updates.toJson());
  }

  @override
  Updates parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return Updates.fromJson(parsed);
  }

  static Map<String, dynamic> get _defaultValue => Updates(
          timetable: '',
          substitutionPlan: '',
          cafetoria: '',
          calendar: '',
          workgroups: '',
          subjects: '',
          minAppLevel: 1,
          grade: '')
      .toMap();
}
