import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

/// Returns 1 if api.vsa.2bad2c0.de is online, 0 if google.com is online and -1 if everthing is offline
Future<int> get checkOnline async {
  try {
    final result1 = await InternetAddress.lookup('api.vsa.2bad2c0.de').timeout(Duration(seconds: 2));
    if (result1.isNotEmpty && result1[0].rawAddress.isNotEmpty) {
      return 1;
    }
    final result2 = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 2));
    if (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) {
      return 0;
    }
    return -1;
  } on SocketException catch (e) {
    print ('Error during checking online: ' + e.toString());
    return -1;
  }
}

Future fetchDataAndSave(String url, String key, String defaultValue) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    final response = await http.Client().get(url).timeout(Duration(seconds: 2));
    sharedPreferences.setString(key, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error during downloading \'$key\': " + e.toString());
    if (sharedPreferences.getString(key) == null) {
      sharedPreferences.setString(key, defaultValue);
    }
  }
}

Future<String> fetchData(String url) async {
  try {
    final response = await http.Client().get(url);
    return response.body;
  } catch (e) {
    print("Error in download: " + e.toString());
    return "";
  }
}
