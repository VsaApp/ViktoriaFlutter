import 'dart:io';

Future<bool> get checkServerConnection async {
  try {
    final result = await InternetAddress.lookup('api.vsa.2bad2c0.de');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}
  
Future<bool> get checkOnline async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}