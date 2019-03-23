import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final teacherFormKey = GlobalKey<FormState>();
  final teacherFocus = FocusNode();
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

  // Check if credentials entered are correct
  void checkForm() async {
    String _username =
        sha256.convert(utf8.encode(usernameController.text)).toString();
    String _password =
        sha256.convert(utf8.encode(passwordController.text)).toString();
    final response = await http.get('https://api.vsa.2bad2c0.de/login/' +
        _username +
        '/' +
        _password +
        '/');
    pupilCredentialsCorrect = json.decode(response.body)['status'];
    if (pupilFormKey.currentState.validate()) {
      // Save correct credentials
      Storage.setString(Keys.username, usernameController.text);
      Storage.setString(Keys.password, passwordController.text);
      Storage.setString(Keys.grade, grade);

      Map<String, dynamic> alreadyInitialized = await isInitialized();
      if (alreadyInitialized != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations
                    .of(context)
                    .loadOldData),
                content:
                Text(AppLocalizations
                    .of(context)
                    .loadOldDataDescription),
                actions: <Widget>[
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
                  FlatButton(
                      child: Text(AppLocalizations
                          .of(context)
                          .no),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/');
                      }),
                ],
              );
            });
      }
      // Show app
      else
        Navigator.pushReplacementNamed(context, '/');
    } else {
      passwordController.clear();
    }
  }
}
