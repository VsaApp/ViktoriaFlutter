import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Downloader/CafetoriaData.dart';
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
    await syncWithTags();
    bool successfully =
        await CafetoriaData().download(context) == StatusCodes.success;
    dataUpdated(context, successfully, AppLocalizations.of(context).cafetoria);
    setState(() {
      saldo = Data.cafetoria.saldo;
      loading = false;
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
      CafetoriaData().download(context).then((_) {
        setState(() {
          saldo = Data.cafetoria.saldo;
          loading = false;
        });
      });
    }
  }
}
