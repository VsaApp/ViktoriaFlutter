import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

/// The downloader structure
abstract class Downloader<type> {
  /// The default data that should be used in the case of errors
  final dynamic defaultData;

  /// The download url
  final String url;

  /// The storage key
  final String key;

  // ignore: public_member_api_docs
  Downloader({
    @required this.defaultData,
    @required this.url,
    @required this.key,
  });

  /// Downloads and saves the data
  ///
  /// If the login data is wrong, the login page will be opened
  Future<int> download(BuildContext context, {bool update = true}) async {
    int status = StatusCodes.success;

    final String oldData = Storage.getString(key);

    if (update || Storage.getString(key) == null) {
      final Completer<int> statusCompleter = Completer();
      // Default timetable (Only for download errors)
      await fetchDataAndSave(url, key, json.encode(defaultData),
          onFinished: statusCompleter.complete);
      status = await statusCompleter.future;

      if (status == StatusCodes.unauthorized && context != null) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }

    // Parse and save data...
    try {
      saveStatic(fetch());
    } catch (e) {
      print('Error: Cannot fetch $key:\n$e');
      if (!update) {
        Storage.setString(key, oldData);
        download(context, update: false);
      }
    }

    return status;
  }

  /// Saves the data in the static `Data` class
  void saveStatic(type data);

  /// Returns the static data
  type getData();

  /// Get data from preferences
  type fetch() {
    return parse(Storage.getString(key));
  }

  /// Returns parsed data
  type parse(String responseBody);
}
