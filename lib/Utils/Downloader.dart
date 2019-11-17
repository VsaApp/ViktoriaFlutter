import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

abstract class Downloader<type> {
  final dynamic defaultData;
  final String url;
  final String key;

  Downloader({
    @required this.defaultData,
    @required this.url,
    @required this.key,
  });

  Future<int> download(BuildContext context, {bool update = true}) async {
    int status = StatusCodes.success;

    if (update || Storage.getString(key) == null) {
      Completer<int> statusCompleter = Completer();
      // Default timetable (Only for download errors)
      await fetchDataAndSave(url, key, json.encode(defaultData),
          onFinished: statusCompleter.complete);
      status = await statusCompleter.future;

      if (status == StatusCodes.unauthorized) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }

    // Parse and save data...
    saveStatic(fetch());

    return status;
  }

  void saveStatic(type data);

  /// Returns the static data...
  type getData();

  /// Get data from preferences...
  type fetch() {
    return parse(Storage.getString(key));
  }

  /// Returns parsed data...
  type parse(String responseBody);
}
