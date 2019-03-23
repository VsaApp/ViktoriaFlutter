import 'dart:io' show File, Platform;

import 'package:device_id/device_id.dart';

class Id {
  static String id;

  static Future init() async {
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

  static bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}
