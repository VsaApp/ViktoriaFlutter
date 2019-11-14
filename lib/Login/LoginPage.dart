import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'LoginView.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageView createState() => LoginPageView();
}

abstract class LoginPageState extends State<LoginPage> {
  final pupilFormKey = GlobalKey<FormState>();
  final pupilFocus = FocusNode();
  int online;
  bool pupilCredentialsCorrect = true;
  bool teacherCredentialsCorrect = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final idController = TextEditingController();
  bool isCheckingForm = false;

  @override
  void initState() {
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((a) {
        MethodChannel('viktoriaflutter').invokeMethod('applyTheme', {
          'color': Theme.of(context)
              .primaryColor
              .value
              .toRadixString(16)
              .substring(2)
              .toUpperCase(),
        });
      });
    }
    super.initState();
  }

  // Check if credentials entered are correct
  void checkForm() async {
    setState(() => isCheckingForm = true);
    Response response = await fetch(
        '$apiUrl/login/'.replaceFirst(
            '://', '://${usernameController.text}:${passwordController.text}@'),
        auth: true);

    try {
      pupilCredentialsCorrect = response.statusCode == StatusCodes.success;
    } catch (e) {
      online = -1;
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToCheckLogin),
          action: SnackBarAction(
            label: AppLocalizations.of(context).ok,
            onPressed: () {},
          ),
        ),
      );
      setState(() => isCheckingForm = false);
      return;
    }

    if (pupilFormKey.currentState.validate()) {
      // Save correct credentials

      askAgbDse(() async {
        Storage.setString(Keys.username, usernameController.text);
        Storage.setString(Keys.password, passwordController.text);

        await syncWithTags();
        Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      passwordController.clear();
    }
    setState(() => isCheckingForm = false);
  }

  launchURL(String url) async {
    if (url == null) return;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void askAgbDse(Function onOk) {
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context1) {
          return SimpleDialog(
              title: Text(AppLocalizations.of(context).agbDse,
                  style: TextStyle(color: Theme.of(context).accentColor)),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(AppLocalizations.of(context).acceptDseAndAgb)),
                Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            child: Text(
                              AppLocalizations.of(context).readAgbDse,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              textAlign: TextAlign.end,
                            ),
                            onPressed: () => launchURL(agbUrl),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                      AppLocalizations.of(context).reject,
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                      textAlign: TextAlign.end),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text(
                                        AppLocalizations.of(context).accept,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor),
                                        textAlign: TextAlign.end),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      onOk();
                                    }),
                              ])
                        ]))
              ]);
        });
  }
}
