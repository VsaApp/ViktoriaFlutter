import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class TeachersData extends Downloader<List<Teacher>> {
  TeachersData()
      : super(
          url: Urls.teachers,
          key: Keys.teachers,
          defaultData: [],
        );

  @override
  List<Teacher> getData() {
    return Data.teachers;
  }

  @override
  void saveStatic(List<Teacher> data) {
    Data.teachers = data;
  }

  @override
  List<Teacher> parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return parsed.map<Teacher>((json) => Teacher.fromJson(json)).toList();
  }
}