import 'package:flutter/material.dart';

import '../Keys.dart';
import '../Storage.dart';
import '../Update.dart';
import '../Localizations.dart';
import 'CafetoriaData.dart';
import 'CafetoriaModel.dart';
import 'CafetoriaView.dart';

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

abstract class CafetoriaPageState extends State<CafetoriaPage> {
  double saldo = Cafetoria.menues.saldo;
  bool loading = true;

  Future reload() async {
    setState(() {
     loading = true; 
    });
    download(onFinished: (successfully) {
      dataUpdated(context, successfully, AppLocalizations.of(context).cafetoria);
    }).then((a) {
      setState(() {
        saldo = Cafetoria.menues.saldo;
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (Storage.getString(Keys.cafetoriaId) == null ||
        Storage.getString(Keys.cafetoriaPassword) == null) {
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
  }
}
