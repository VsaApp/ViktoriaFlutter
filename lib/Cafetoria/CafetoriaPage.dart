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

  Future update() async {
    data = await download();
    setState(() => this.data = data);
  }

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
}
