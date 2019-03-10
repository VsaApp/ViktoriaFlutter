import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import 'CafetoriaData.dart';
import 'CafetoriaModel.dart';
import 'CafetoriaView.dart';

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

abstract class CafetoriaPageState extends State<CafetoriaPage> {
  SharedPreferences sharedPreferences;
  double saldo = Cafetoria.menues.saldo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instance) {
      sharedPreferences = instance;
      if (sharedPreferences.getString(Keys.cafetoriaId) == null ||
          sharedPreferences.getString(Keys.cafetoriaPassword) == null) {
        setState(() {
          loading = false;
        });
      } else {
        download().then((a) {
          setState(() {
            saldo = Cafetoria.menues.saldo;
            loading = false;
          });
        });
      }
    });
  }
}
