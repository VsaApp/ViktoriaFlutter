import 'dart:io' show File, Platform;

import 'package:device_id/device_id.dart';

import 'Keys.dart';
import 'Storage.dart';

class Id {
  static String id;

  static Future init() async {
    if (Storage.getString(Keys.id) != null) {
      id = Storage.getString(Keys.id);
    } else {
      if (_isDesktop) {
        if (Platform.isLinux) {
          id = File('/etc/machine-id').readAsStringSync();
        } else {
          throw 'This platform is not supported yet';
        }
      } else {
        id = await DeviceId.getID;
      }
    }
  }

  static void overrideId(String id) {
    Id.id = id;
    Storage.setString(Keys.id, id);
  }

  static bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}
