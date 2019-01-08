import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CafetoriaData.dart';
import 'CafetoriaModel.dart';
import 'CafetoriaView.dart';

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

abstract class CafetoriaPageState extends State<CafetoriaPage> {
  SharedPreferences sharedPreferences;
  Cafetoria data;

  @override
  void initState() {
    // Download data
    download().then((data) {
      setState(() {
        this.data = data;
      });
    });
    super.initState();
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
}
