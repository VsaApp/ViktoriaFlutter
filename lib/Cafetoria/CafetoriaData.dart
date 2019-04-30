import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'CafetoriaModel.dart';

// Download cafetoria data from the api...
Future download({String id, String password, bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    // If id and password is not set, load login data from preferences...
    String url = '/cafetoria/login/' +
        ((id != null) ? id : Storage.getString(Keys.cafetoriaId) ?? 'null') +
        '/' +
        ((password != null)
            ? password
            : Storage.getString(Keys.cafetoriaPassword) ?? 'null');
    await fetchDataAndSave(url, Keys.cafetoria, '{}', onFinished: (bool v) => successfully = v);
  }

  Cafetoria.menues = await fetchDays();
  if (onFinished != null) onFinished(successfully);
}

// Check the login data of the keyfob...
Future<bool> checkLogin({String id, String password}) async {
  try {
    String url = '/cafetoria/login/' +
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
