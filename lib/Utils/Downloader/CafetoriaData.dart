import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

class CafetoriaData extends Downloader<Cafetoria> {
  CafetoriaData()
      : super(
          url: _url,
          key: Keys.cafetoria,
          defaultData: {
            "saldo": null,
            "error": null,
            "days": [],
          },
        );

  @override
  Cafetoria getData() {
    return Data.cafetoria;
  }

  @override
  void saveStatic(Cafetoria data) {
    Data.cafetoria = data;
  }

  @override
  Cafetoria parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return Cafetoria.fromJson(parsed);
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

  static String get _url {
    String id = Storage.getString(Keys.cafetoriaId);
    String password = Storage.getString(Keys.cafetoriaPassword);

    if (id != null && password != null) {
      return Urls.cafetoriaLogin(id, password);
    }

    return Urls.cafetoriaList;
  }
}
