import 'dart:convert';

import 'package:viktoriaflutter/Keys.dart';
import 'package:viktoriaflutter/Notices/NoticesModel.dart';
import 'package:viktoriaflutter/Storage.dart';

void load() {
  String data = Storage.getString(Keys.notices) ?? '[]';
  Notices.notices = json
      .decode(data)
      .map((notice) =>
          Notice.fromJSON(json.decode(notice).cast<String, String>()))
      .toList()
      .cast<Notice>();
}
