import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import 'CafetoriaModel.dart';

// Download cafetoria data from the api...
Future<Cafetoria> download({String id, String password, bool parse}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    // If id and password is not set, load login data from preferences...
    String _url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
        ((id != null)
            ? id
            : sharedPreferences.getString(Keys.cafetoriaId) ?? 'null') +
        '/' +
        ((password != null)
            ? password
            : sharedPreferences.getString(Keys.cafetoriaPassword) ?? 'null');

    final response = await http.Client().get(_url);
    sharedPreferences.setString(Keys.cafetoria, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.cafetoria) == null) {
      sharedPreferences.setString(Keys.cafetoria, '{}');
    }
  }

  // Parse the downloaded data...
  if (parse == null || !parse) return await fetchDays();
}

// Check the login data of the keyfob...
Future<bool> checkLogin({String id, String password}) async {
  try {
    String _url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
        id +
        '/' +
        password +
        '/';

    final response = await http.Client().get(_url);
    final parsed = json.decode(response.body);
    return CafetoriaLogin.fromJson(parsed).error == null;
  } catch (e) {
    print("Error in download: " + e.toString());
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
