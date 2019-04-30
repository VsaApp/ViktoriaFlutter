import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'ActionFAB/ActionFABWidget.dart';
import 'CafetoriaData.dart';
import 'CafetoriaModel.dart';
import 'CafetoriaPage.dart';
import 'DayCard/DayCardWidget.dart';
import 'LoginDialog/LoginDialogWidget.dart';

class CafetoriaPageView extends CafetoriaPageState {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              padding: EdgeInsets.only(bottom: 70, left: 10, right: 10, top: 10),
              shrinkWrap: true,
              children: Cafetoria.menues.days
                  .map((day) => CafetoriaDayCard(
                        day: day,
                        showWeekday: true,
                      ))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
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
                            download().then((a) {
                              setState(() {
                                saldo = Cafetoria.menues.saldo;
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
