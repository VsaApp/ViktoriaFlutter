import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

// Download cafetoria data from the api...
Future download(
    {String id,
    String password,
    bool update = true,
    Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    // If id and password is not set, load login data from preferences...
    id = id ?? Storage.getString(Keys.cafetoriaId);
    password = password ?? Storage.getString(Keys.cafetoriaPassword);
    // Get the personalized or non personalized url
    String url;
    if (id != null && password != null) {
      url = Urls.cafetoriaLogin(id, password);
    } else {
      url = Urls.cafetoriaList;
    }
    // The default response (Only for errors)
    String defaultJson = json.encode({
      "saldo": null,
      "error": null,
      "days": [],
    });
    await fetchDataAndSave(
      url,
      Keys.cafetoria,
      defaultJson,
      onFinished: (int status) => successfully = status == StatusCodes.success,
    );
  }

  Data.cafetoria = await fetchCafetoria();
  if (onFinished != null) onFinished(successfully);
}

// Check the login data of the keyfob...
Future<bool> checkLogin({String id, String password}) async {
  try {
    String url = Urls.cafetoriaLogin(id, password);
    Response response = await fetch(url);
    if (response.statusCode != StatusCodes.success)
      throw 'Failed to check login';
    return json.decode(response.body)['error'] == null;
  } catch (e) {
    return false;
  }
}

// Load the preferences data...
Future<Cafetoria> fetchCafetoria() async {
  return parseCafetoria(Storage.getString(Keys.cafetoria));
}

// Parse the json string to the model structure...
Cafetoria parseCafetoria(String responseBody) {
  final parsed = json.decode(responseBody);
  return Cafetoria.fromJson(parsed);
}
