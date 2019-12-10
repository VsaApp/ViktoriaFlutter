import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Downloader/CafetoriaData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'CafetoriaView.dart';

/// This Page shows all menus for the current week and the user saldo if logged in
class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

// ignore: public_member_api_docs
abstract class CafetoriaPageState extends State<CafetoriaPage> {
  /// The current keyfob saldo
  double saldo = Data.cafetoria.saldo;

  /// The current data loading state
  bool loading = true;

  /// Reloads the cafetoria data
  Future reload() async {
    setState(() {
      loading = true;
    });
    await syncWithTags();
    final successfully =
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
