import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

/// Timetable data downloader
class TimetableData extends Downloader<Timetable> {
  // ignore: public_member_api_docs
  TimetableData()
      : super(
          url: Urls.timetable,
          key: Keys.timetable(Storage.getString(Keys.grade)),
          defaultData: {
            'grade': Storage.getString(Keys.grade),
            'date': DateTime.now().toIso8601String(),
            'data': {
              'grade': Storage.getString(Keys.grade),
              'days': [],
            }
          },
        );

  @override
  Future<int> download(BuildContext context, {bool update = true, Map<String, dynamic> body}) async {
    final String currentTimetable = Storage.getString(key);
    final int status = await super.download(context, update: update);
    final String newTimetable = Storage.getString(key);
    checkTimetableUpdated(currentTimetable, newTimetable);
    return status;
  }

  @override
  Timetable getData() {
    return Data.timetable;
  }

  @override
  void saveStatic(Timetable data) {
    Data.timetable = data;
    Data.timetable.setAllSelections();
  }

  @override
  Timetable parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return Timetable.fromJSON(parsed);
  }

  /// Resets the selected subjects when the timetable changed
  Future checkTimetableUpdated(String version1, String version2) async {
    if (version1 == null || version2 == null) {
      return;
    }
    version1 = version1.replaceFirst(RegExp('"date":"(.*?)"'), '');
    version2 = version2.replaceFirst(RegExp('"date":"(.*?)"'), '');
    if (version1 != version2) {
      Storage.setBool(Keys.timetableIsNew, true);
      print('There is a new timetable, reset old data');
      Storage.getKeys()
        .where((String key) =>
            key.startsWith(Keys.selection('')) ||
            key.startsWith(Keys.exams(''))).toList()
        .forEach(Storage.remove);
    }
  }
}
