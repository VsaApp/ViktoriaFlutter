import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import 'LoginView.dart';

/// Page to handle the user login
class LoginPage extends StatefulWidget {
  @override
  LoginPageView createState() => LoginPageView();
}

// ignore: public_member_api_docs
abstract class LoginPageState extends State<LoginPage> {
  /// Key of the login form
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// Focus node for the password text field
  final FocusNode passwordFocus = FocusNode();

  /// Defines if the app is online
  int online;

  /// Defines if the credentials are correct
  bool credentialsCorrect = true;

  /// Controller for username text field
  final TextEditingController usernameController = TextEditingController();

  /// Controller for password text field
  final TextEditingController passwordController = TextEditingController();

  /// Defines if currently checks the credentials
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

  /// Check if credentials entered are correct
  Future checkForm() async {
    setState(() => isCheckingForm = true);
    final Response response = await fetch(
        '$apiUrl/login/'.replaceFirst(
            '://', '://${usernameController.text}:${passwordController.text}@'),
        auth: true);

    try {
      credentialsCorrect = response.statusCode == StatusCodes.success;
    } catch (e) {
      online = -1;
      if (MainFrameState.isInForeground) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToCheckLogin),
            action: SnackBarAction(
              label: AppLocalizations.of(context).ok,
              onPressed: () {},
            ),
          ),
        );
      }
      setState(() => isCheckingForm = false);
      return;
    }

    if (loginFormKey.currentState.validate()) {
      // Save correct credentials

      askAgbDse(() async {
        Storage.setString(Keys.username, usernameController.text);
        Storage.setString(Keys.password, passwordController.text);

        Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      passwordController.clear();
    }
    setState(() => isCheckingForm = false);
  }

  /// Launches an url in the default browser
  Future launchURL(String url) async {
    if (url == null) {
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Ask the user to accept the agb and dse
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
                            onPressed: () => launchURL(agbUrl),
                            child: Text(
                              AppLocalizations.of(context).readAgbDse,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      AppLocalizations.of(context).reject,
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                      textAlign: TextAlign.end),
                                ),
                                FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onOk();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context).accept,
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                      textAlign: TextAlign.end),
                                ),
                              ])
                        ]))
              ]);
        });
  }
}
