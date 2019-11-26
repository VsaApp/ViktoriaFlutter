import 'package:test/test.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'storage_test.dart' as storage;

void main({bool main = true}) {
  storage.init();

  group('Tags', () {
    test('Get tags', () async {
      expect(await getTags(), isNotNull);
    });
    test('Sync with tags', () async {
      expect(Storage.getString(Keys.lastModified), isNull);
      expect(
        Storage.getKeys().where((i) => i.startsWith(Keys.selection(''))).length,
        0,
      );
      expect(
        Storage.getKeys().where((i) => i.startsWith(Keys.exams(''))).length,
        0,
      );
      expect(await syncWithTags(), true);
      expect(
        Storage.getKeys()
            .where((i) => i.startsWith(Keys.selection('')))
            .isNotEmpty,
        true,
      );
      expect(
        Storage.getKeys().where((i) => i.startsWith(Keys.exams(''))).isNotEmpty,
        true,
      );
      expect(Storage.getString(Keys.lastModified), isNotNull);
    });
  });
}
