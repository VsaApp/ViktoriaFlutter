import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class RoomsData extends Downloader<Map<String, String>> {
  RoomsData()
      : super(
          url: Urls.rooms,
          key: Keys.rooms,
          defaultData: {},
        );

  @override
  Map<String, String> getData() {
    return Data.rooms;
  }

  @override
  void saveStatic(Map<String, String> data) {
    Data.rooms = data;
  }

  @override
  Map<String, String> parse(String responseBody) {
    return json.decode(responseBody).cast<String, String>();
  }
}