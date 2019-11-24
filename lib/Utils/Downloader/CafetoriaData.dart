import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

/// Cafetoria data downloader
class CafetoriaData extends Downloader<Cafetoria> {
  // ignore: public_member_api_docs
  CafetoriaData()
      : super(
          url: _url,
          key: Keys.cafetoria,
          defaultData: const {
            'saldo': null,
            'error': null,
            'days': [],
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

  /// Check the login data of the keyfob...
  Future<bool> checkLogin({String id, String password}) async {
    try {
      final String url = Urls.cafetoriaLogin(id, password);
      final Response response = await fetch(url);
      if (response.statusCode != StatusCodes.success) {
        throw Exception('Failed to check login');
      }
      return json.decode(response.body)['error'] == null;
    } catch (e) {
      return false;
    }
  }

  static String get _url {
    final String id = Storage.getString(Keys.cafetoriaId);
    final String password = Storage.getString(Keys.cafetoriaPassword);

    if (id != null && password != null) {
      return Urls.cafetoriaLogin(id, password);
    }

    return Urls.cafetoriaList;
  }
}
