import 'package:flutter/services.dart' show rootBundle;

import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

/// Initialize bugs report
Future init() async {
  final List<String> bugs = Storage.getStringList(Keys.bugs) ?? [];
  if (bugs.isNotEmpty && (await checkOnline) == 1) {
    bugs.forEach((String bug) {
      reportError(bug.split(':|:')[0], bug.split(':|:')[1]);
    });
    Storage.setStringList(Keys.bugs, []);
  }
}

/// Report a new error
// ignore: type_annotate_public_apis
Future<void> reportError(error, stackTrace) async {
  print('Report new bug ($error)');
  if ((await checkOnline) == 1) {
    String version;
    try {
      version = (await rootBundle.loadString('pubspec.yaml'))
        .split('\n')
        .where((line) => line.startsWith('version'))
        .toList()[0]
        .split(':')[1]
        .trim();
    }
    catch (_) {
      version = '';
    }
    try {
      httpPost(Urls.bugReport, body: {
        'username': Storage.getString(Keys.username),
        'title': error.toString(),
        'error': stackTrace.toString(),
        'version': version == '' ? null : version
      });
    } catch (_) {
      Storage.setStringList(Keys.bugs, Storage.getStringList(Keys.bugs)..add('$error:|:$stackTrace'));
    }
  } else {
    Storage.setStringList(Keys.bugs, Storage.getStringList(Keys.bugs)..add('$error:|:$stackTrace'));
  }
}

