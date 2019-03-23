import 'dart:async';
import 'dart:convert';

import '../Keys.dart';
import '../Network.dart';
import '../Storage.dart';
import 'CafetoriaModel.dart';

// Download cafetoria data from the api...
Future download({String id, String password}) async {
  // If id and password is not set, load login data from preferences...
  String url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
      ((id != null) ? id : Storage.getString(Keys.cafetoriaId) ?? 'null') +
      '/' +
      ((password != null)
          ? password
          : Storage.getString(Keys.cafetoriaPassword) ?? 'null');
  await fetchDataAndSave(url, Keys.cafetoria, '{}');

  Cafetoria.menues = await fetchDays();
}

// Check the login data of the keyfob...
Future<bool> checkLogin({String id, String password}) async {
  try {
    String url = 'https://api.vsa.2bad2c0.de/cafetoria/login/' +
        id +
        '/' +
        password +
        '/';
    return json.decode(await fetchData(url))['error'] == null;
  } catch (e) {
    return false;
  }
}

// Load the preferences data...
Future<CafetoriaMenues> fetchDays() async {
  return parseDays(Storage.getString(Keys.cafetoria));
}

// Parse the json string to the model structure...
CafetoriaMenues parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return CafetoriaMenues.fromJson(parsed);
}
