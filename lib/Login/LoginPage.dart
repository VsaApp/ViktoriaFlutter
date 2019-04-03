import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Network.dart';
import '../Id.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Storage.dart';
import '../Tags.dart';
import 'LoginView.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageView createState() => LoginPageView();
}

abstract class LoginPageState extends State<LoginPage> {
  final pupilFormKey = GlobalKey<FormState>();
  final pupilFocus = FocusNode();
  bool pupilCredentialsCorrect = true;
  bool teacherCredentialsCorrect = true;
  static List<String> grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];
  String grade = grades[0];
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final idController = TextEditingController();

  // Check if credentials entered are correct
  void checkForm() async {
    String _username =
        sha256.convert(utf8.encode(usernameController.text)).toString();
    String _password =
        sha256.convert(utf8.encode(passwordController.text)).toString();
    final response = await httpGet('/login/$_username/$_password/', auth: false);
    pupilCredentialsCorrect = json.decode(response)['status'];
    if (pupilFormKey.currentState.validate()) {
      // Save correct credentials

      askAgbDse(() async {
        Storage.setString(Keys.username, usernameController.text);
        Storage.setString(Keys.password, passwordController.text);
        Storage.setString(Keys.grade, grade);

        Map<String, dynamic> alreadyInitialized = await isInitialized();
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          askSync();
        } else if (alreadyInitialized != null) {
          askOldDataLoading();
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      });

      
    } else {
      passwordController.clear();
    }
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
          title: Text(AppLocalizations.of(context).agbDse, style: TextStyle(color: Theme.of(context).accentColor)),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20), 
              child: Text(AppLocalizations.of(context).accecptDseAndAgb)
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Text(AppLocalizations.of(context).readAgbDse, style: TextStyle(color: Theme.of(context).accentColor), textAlign: TextAlign.end,),
                    onPressed: () => launchURL(agbUrl),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Text(AppLocalizations.of(context).reject, style: TextStyle(color: Theme.of(context).accentColor), textAlign: TextAlign.end),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Text(AppLocalizations.of(context).accept, style: TextStyle(color: Theme.of(context).accentColor), textAlign: TextAlign.end),
                      onPressed: () {
                        Navigator.pop(context);
                        onOk();
                      }
                    ),
                  ])
                ]
              )
            )
          ]
        );
      }
    );
  }

  void askSync() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations
                .of(context)
                .syncPhone),
            content: Column(
              children: <Widget>[
                Text(AppLocalizations
                    .of(context)
                    .syncPhoneDescription),
                TextFormField(
                  controller: idController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations
                          .of(context)
                          .fieldCantBeEmpty;
                    }
                  },
                  decoration: InputDecoration(
                      hintText: AppLocalizations
                          .of(context)
                          .syncPhoneId),
                  onFieldSubmitted: (value) async {
                    Id.overrideId(value);
                    print(value);
                    Map<String, dynamic> alreadyInitialized =
                    await isInitialized();
                    if (alreadyInitialized != null) {
                      askOldDataLoading();
                    } else {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  obscureText: false,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations
                    .of(context)
                    .skip),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              FlatButton(
                child: Text(AppLocalizations
                    .of(context)
                    .ok),
                onPressed: () async {
                  Id.overrideId(idController.text);
                  await syncWithTags();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          );
        });
  }

  void askOldDataLoading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations
                .of(context)
                .loadOldData),
            content: Text(AppLocalizations
                .of(context)
                .loadOldDataDescription),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations
                    .of(context)
                    .no),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              FlatButton(
                child: Text(AppLocalizations
                    .of(context)
                    .yes),
                onPressed: () async {
                  await syncWithTags();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          );
        });
  }
}
