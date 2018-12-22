import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/Cafetoria.dart';

Future<Cafetoria> download({String id, String password, bool parse}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    String _url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
        ((id != null)
            ? id
            : sharedPreferences.getString(Keys.cafetoriaUsername) ?? 'null') +
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

  if (parse == null || !parse) return await fetchDays();
}

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

Future<Cafetoria> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(sharedPreferences.getString(Keys.cafetoria));
}

Cafetoria parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return Cafetoria.fromJson(parsed);
}
