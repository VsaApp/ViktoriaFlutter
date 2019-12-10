import 'dart:convert';

import 'package:viktoriaflutter/Downloader/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Models/Models.dart';

/// Subjects data downloader
class SubjectsData extends Downloader<Map<String, String>> {
  // ignore: public_member_api_docs
  SubjectsData()
      : super(
          url: Urls.subjects,
          key: Keys.subjects,
          defaultData: {},
        );

  @override
  Map<String, String> getData() {
    return Data.subjects;
  }

  @override
  void saveStatic(Map<String, String> data) {
    Data.subjects = data;
  }

  @override
  Map<String, String> parse(String responseBody) {
    final parsed = json.decode(responseBody).map<String, String>(
      (key, value) => MapEntry<String, String>(key, value as String));
    return parsed;
  }
}

