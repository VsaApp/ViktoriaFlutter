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

Future fetchDataAndSave(String url, String key, String defaultValue) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    final response = await http.Client().get(url);
    sharedPreferences.setString(key, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
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
