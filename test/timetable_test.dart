import 'package:test/test.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

import 'config.dart';
import 'storage_test.dart' as storage;

void main({bool main = true}) {
  if (main) {
    storage.init();
  }

  group('Timetable', () {
    test('Downloaded all days', () async {
      await TimetableData().download(null);
      expect(Data.timetable.days.length, 5);
    });
    test('New timetable', () async {
      Storage.setBool(Keys.selection('exampleCourse'), true);
      Storage.setBool(Keys.exams('exampleCourse'), true);
      final String timetable =
          Storage.getString(Keys.timetable(config['grade']));
      final String v2 = timetable.replaceFirst(
          RegExp('"date":"(.*?)"'), '"date":"2000-11-24T14:48:58.389Z"');

      /// Check with only a different date
      final data = TimetableData();
      await data.checkTimetableUpdated(timetable, v2);
      expect(Storage.getBool(Keys.timetableIsNew) ?? false, false);
      expect(Storage.getBool(Keys.selection('exampleCourse')), true);
      expect(Storage.getBool(Keys.exams('exampleCourse')), true);

      /// Check with different content
      await data.checkTimetableUpdated(timetable, '$v2 ...');
      expect(Storage.getBool(Keys.timetableIsNew), true);
      expect(Storage.getBool(Keys.selection('exampleCourse')), isNull);
      expect(Storage.getBool(Keys.exams('exampleCourse')), isNull);
    });
  });
}
