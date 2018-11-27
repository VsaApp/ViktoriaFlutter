import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Localizations.dart';
import '../Keys.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginView createState() => LoginView();
}

class LoginView extends State<LoginPage> {
  String _type = '';
  final _pupilFormKey = GlobalKey<FormState>();
  final _pupilFocus = FocusNode();
  bool _pupilCredentialsCorrect = true;
  static List<String> _grades = [
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
  String _grade = _grades[0];
  final _pupilUsernameController = TextEditingController();
  final _pupilPasswordController = TextEditingController();

  void checkPupilForm() async {
    String _username =
        sha256.convert(utf8.encode(_pupilUsernameController.text)).toString();
    String _password =
        sha256.convert(utf8.encode(_pupilPasswordController.text)).toString();
    final response = await http.get(
        'https://api.vsa.lohl1kohl.de/validate?username=' +
            _username +
            '&password=' +
            _password);
    _pupilCredentialsCorrect = response.body == '0';
    if (_pupilFormKey.currentState.validate()) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(Keys.username, _pupilUsernameController.text);
      sharedPreferences.setString(Keys.password, _pupilPasswordController.text);
      sharedPreferences.setString(Keys.grade, _grade);
      sharedPreferences.setBool(Keys.isTeacher, false);
      sharedPreferences.commit();
      Navigator.pushReplacementNamed(context, '/');
    } else {
      _pupilPasswordController.clear();
    }
  }

  @override
  void dispose() {
    _pupilUsernameController.dispose();
    _pupilPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_type == '') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context1) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context).pleaseSelect),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _type = 'pupil';
                      });
                    },
                    child: Text(AppLocalizations.of(context).pupil),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _type = 'teacher';
                      });
                    },
                    child: Text(AppLocalizations.of(context).teacher),
                  ),
                ],
              );
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/images/logo.png'), context);
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Image.asset(
                'assets/images/logo.png',
                height: 125.0,
              ),
            ),
            Center(
              child: Text(
                AppLocalizations.of(context).title,
                style: TextStyle(fontSize: 25),
              ),
            ),
            (_type == ''
                ? Container()
                : (_type == 'pupil'
                    ? Form(
                        key: _pupilFormKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  items: _grades.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  value: _grade,
                                  onChanged: (grade) {
                                    setState(() {
                                      _grade = grade;
                                    });
                                  },
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _pupilUsernameController,
                              onSaved: (value) {
                                print(value);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .fieldCantBeEmpty;
                                }
                                if (!_pupilCredentialsCorrect) {
                                  return AppLocalizations.of(context)
                                      .credentialsNotCorrect;
                                }
                              },
                              decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context).username),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(_pupilFocus);
                              },
                            ),
                            TextFormField(
                              controller: _pupilPasswordController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .fieldCantBeEmpty;
                                }
                                if (!_pupilCredentialsCorrect) {
                                  return AppLocalizations.of(context)
                                      .credentialsNotCorrect;
                                }
                              },
                              decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context).password),
                              onFieldSubmitted: (value) {
                                checkPupilForm();
                              },
                              obscureText: true,
                              focusNode: _pupilFocus,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  onPressed: () {
                                    checkPupilForm();
                                  },
                                  child:
                                      Text(AppLocalizations.of(context).login),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(AppLocalizations.of(context).notImplementedYet)))
          ],
        ),
      ),
    );
  }
}
