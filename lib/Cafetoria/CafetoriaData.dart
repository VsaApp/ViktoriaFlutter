import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import 'CafetoriaModel.dart';

// Download cafetoria data from the api...
Future<Cafetoria> download({String id, String password, bool parse}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // If id and password is not set, load login data from preferences...
  String url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
      ((id != null) ? id: sharedPreferences.getString(Keys.cafetoriaId) ?? 'null') + '/' +
      ((password != null) ? password : sharedPreferences.getString(Keys.cafetoriaPassword) ?? 'null');
  await fetchDataAndSave(url, Keys.cafetoria, '{}');

  // Parse the downloaded data...
  if (parse == null || !parse) return await fetchDays();
  return null;
}

// Check the login data of the keyfob...
Future<bool> checkLogin({String id, String password}) async {
  try {
    String url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' + id + '/' + password + '/';
    return json.decode(await fetchData(url)).error == null;
  } catch (e) {
    return false;
  }
}

// Load the preferences data...
Future<Cafetoria> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(sharedPreferences.getString(Keys.cafetoria));
}

// Parse the json string to the model structure...
Cafetoria parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return Cafetoria.fromJson(parsed);
}
