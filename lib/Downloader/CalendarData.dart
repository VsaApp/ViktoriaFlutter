import 'dart:convert';

import 'package:viktoriaflutter/Downloader/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Models/Models.dart';

/// Calendar data downloader
class CalendarData extends Downloader<Calendar> {
  // ignore: public_member_api_docs
  CalendarData()
      : super(
          url: Urls.calendar,
          key: Keys.calendar,
          defaultData: {'years': [], 'data': []},
        );

  @override
  Calendar getData() {
    return Data.calendar;
  }

  @override
  void saveStatic(Calendar data) {
    Data.calendar = data;
  }

  @override
  Calendar parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return Calendar.fromJson(parsed);
  }
}
