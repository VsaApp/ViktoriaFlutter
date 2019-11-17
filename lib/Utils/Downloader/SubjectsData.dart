import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class SubjectsData extends Downloader<Map<String, String>> {
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

