import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'CafetoriaData.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'CafetoriaView.dart';

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

abstract class CafetoriaPageState extends State<CafetoriaPage> {
  double saldo = Data.cafetoria.saldo;
  bool loading = true;

  Future reload() async {
    setState(() {
      loading = true;
    });
    download(onFinished: (successfully) {
      dataUpdated(
          context, successfully, AppLocalizations.of(context).cafetoria);
    }).then((a) {
      setState(() {
        saldo = Data.cafetoria.saldo;
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
          saldo = Data.cafetoria.saldo;
          loading = false;
        });
      });
    }
  }
}
