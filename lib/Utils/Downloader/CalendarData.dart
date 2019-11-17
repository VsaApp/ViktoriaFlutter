import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class CalendarData extends Downloader<Calendar> {
  CalendarData()
      : super(
          url: Urls.calendar,
          key: Keys.calendar,
          defaultData: {"years": [], "data": []},
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
