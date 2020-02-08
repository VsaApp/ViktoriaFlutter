import 'dart:convert';
import 'package:test/test.dart';
import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Downloader/CafetoriaData.dart';
import 'package:viktoriaflutter/Utils/Downloader/CalendarData.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubjectsData.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Utils/Downloader/UpdatesData.dart';
import 'package:viktoriaflutter/Utils/Downloader/WorkGroupsData.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

import 'config.dart';
import 'storage_test.dart' as storage;

void main({bool main = true}) {
  if (main) {
    storage.init();
  }
  // ignore: unused_local_variable
  final Map<String, Downloader> _downloader = {
    'timetable': TimetableData(),
    'substitution plan': SubstitutionPlanData(),
    'cafetoria': CafetoriaData(),
    'calendar': CalendarData(),
    'subjects': SubjectsData(),
    'updates': UpdatesData(),
    'work groups': WorkGroupsData(),
  }..forEach(downloader);
}

void downloader(String name, Downloader data) {
  group('$name downloader', () {
    test('$name data', () {
      expect(data, isNotNull);
    });
    test('Downloader url', () {
      expect(data.url, startsWith(data.url.split('?')[0]));
    });
    test('Default data', () {
      expect(data.parse(json.encode(data.defaultData)), isNotNull);
    });
    test('Download data', () async {
      expect(data.getData(), isNull);
      expect(Storage.getString(data.key), isNull);
      expect(await data.download(null), StatusCodes.success);
      expect(data.getData(), isNotNull);
      if (name != 'updates') {
        expect(Storage.getString(data.key), isNotNull);
      }
    });
    test('Download data with wrong login data', () async {
      Storage.setString(Keys.username, 'username');
      expect(await data.download(null), StatusCodes.unauthorized);
      expect(data.getData(), isNotNull);
      Storage.setString(Keys.username, config['username']);
    });
  });
}
