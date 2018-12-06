import 'package:flutter/services.dart';

class Viktoriaflutterplugin {
  static const MethodChannel _channel =
      const MethodChannel('viktoriaflutterplugin');

  static void showNotification(String json) {
    _channel.invokeMethod(json);
  }
}
