import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import 'config.dart';

void setDefaultStorage() {
  File('.data.json').writeAsStringSync(json.encode({
    'grade': config['grade'],
    'username': config['username'],
    'password': config['password']
  }));
}

void init() {
  setDefaultStorage();
  Storage.init();
}

void main() {
  group('Storage', () {
    test('Init storage', () {
      init();
      expect(Storage.getKeys(), isNotNull);
    });
    test('set string', () {
      const String key = 'testKey';
      const String value = '123';
      expect(Storage.getString(key), isNull);
      Storage.setString(key, value);
      expect(Storage.getString(key), value);
      Storage.remove(key);
      expect(Storage.getString(key), isNull);
    });
  });
}
