import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaflutter/Downloader/CafetoriaData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

import 'ActionFAB/ActionFABWidget.dart';
import 'CafetoriaPage.dart';
import 'DayCard/DayCardWidget.dart';
import 'LoginDialog/LoginDialogWidget.dart';

// ignore: public_member_api_docs
class CafetoriaPageView extends CafetoriaPageState {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              padding:
                  EdgeInsets.only(bottom: 70, left: 10, right: 10, top: 10),
              shrinkWrap: true,
              children: Data.cafetoria.days
                  .map((day) => CafetoriaDayCard(
                        day: day,
                        showWeekday: true,
                      ))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              child: ActionFab(
                onLogin: () {
                  showDialog<String>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context1) {
                      return SimpleDialog(
                        title:
                            Text(AppLocalizations.of(context).cafetoriaLogin),
                        children: <Widget>[
                          LoginDialog(onFinished: () {
                            CafetoriaData().download(context).then((_) {
                              setState(() {
                                saldo = Data.cafetoria.saldo;
                              });
                            });
                          })
                        ],
                      );
                    },
                  );
                },
                onOrder: () {
                  launch('https://www.opc-asp.de/vs-aachen/');
                },
                loading: loading,
                saldo: saldo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
