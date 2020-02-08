import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
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
          url: Urls.cafetoria,
          key: Keys.cafetoria,
          defaultData: const {
            'saldo': null,
            'error': null,
            'days': [],
          },
        );

  @override
  Future<int> download(BuildContext context,
      {bool update = true, Map<String, dynamic> body}) {
    final id = Storage.getString(Keys.cafetoriaId);
    final password = Storage.getString(Keys.cafetoriaPassword);
    Map<String, String> body;
    if (id != null && password != null) {
      body = {'id': id, 'pin': password};
    }

    return super.download(context, update: update, body: body);
  }

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
      final String url = Urls.cafetoria;
      final Response response = await fetch(url);
      if (response.statusCode != StatusCodes.success) {
        throw Exception('Failed to check login');
      }
      return json.decode(response.body)['error'] == null;
    } catch (e) {
      return false;
    }
  }
}
