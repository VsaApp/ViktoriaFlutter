import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Localizations.dart';
import 'ActionFAB/ActionFABWidget.dart';
import 'CafetoriaData.dart';
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
          data == null
              ?
              // Show loader
              Scaffold(
                  body: Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(strokeWidth: 5.0),
                      height: 75.0,
                      width: 75.0,
                    ),
                  ),
                )
              : RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: update,
            child: ListView(
              padding: EdgeInsets.only(
                  bottom: 70, left: 10, right: 10, top: 10),
              shrinkWrap: true,
              children:
              data.days.map((day) => DayCard(day: day)).toList(),
            ),
          ),
          data == null
              ?
              // And disable FAB while loading
              Container()
              : Positioned(
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
                                title: Text(AppLocalizations.of(context)
                                    .cafetoriaLogin),
                                children: <Widget>[
                                  LoginDialog(onFinished: () {
                                    setState(() {
                                      this.data = null;
                                    });
                                    download().then((data) {
                                      setState(() {
                                        this.data = data;
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
                        saldo: (data == null) ? -1.0 : data.saldo),
                  ),
                ),
        ],
      ),
    );
  }
}
