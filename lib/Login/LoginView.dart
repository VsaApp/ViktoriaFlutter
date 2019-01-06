import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginView createState() => LoginView();
}

class LoginView extends State<LoginPage> {
  String _type = '';
  final _pupilFormKey = GlobalKey<FormState>();
  final _pupilFocus = FocusNode();
  bool _pupilCredentialsCorrect = true;
  final _teacherFormKey = GlobalKey<FormState>();
  final _teacherFocus = FocusNode();
  bool _teacherCredentialsCorrect = true;
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
  final _teacherUsernameController = TextEditingController();
  final _teacherPasswordController = TextEditingController();

  // Check if credentials entered are correct
  void checkPupilForm() async {
    String _username =
        sha256.convert(utf8.encode(_pupilUsernameController.text)).toString();
    String _password =
        sha256.convert(utf8.encode(_pupilPasswordController.text)).toString();
    final response = await http.get('https://api.vsa.2bad2c0.de/login/' +
        _username +
        '/' +
        _password +
        '/');
    _pupilCredentialsCorrect = json.decode(response.body)['status'];
    if (_pupilFormKey.currentState.validate()) {
      // Save correct credentials
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(Keys.username, _pupilUsernameController.text);
      sharedPreferences.setString(Keys.password, _pupilPasswordController.text);
      sharedPreferences.setString(Keys.grade, _grade);
      sharedPreferences.setBool(Keys.isTeacher, false);
      sharedPreferences.commit();
      // Show app
      Navigator.pushReplacementNamed(context, '/');
    } else {
      _pupilPasswordController.clear();
    }
  }

  // Check if credentials entered are correct
  void checkTeacherForm() async {
    String _username = _teacherUsernameController.text.toUpperCase();
    String _password = _teacherPasswordController.text;
    final response = await http
        .get('https://api.vsa.2bad2c0.de/unitplan/' + _username + '.json');
    _teacherCredentialsCorrect = response.statusCode != 404;
    if (_teacherFormKey.currentState.validate()) {
      // Save correct credentials
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(Keys.username, _username);
      sharedPreferences.setString(Keys.password, _password);
      sharedPreferences.setString(Keys.grade, _username);
      sharedPreferences.setBool(Keys.isTeacher, true);
      sharedPreferences.commit();
      // Show app
      Navigator.pushReplacementNamed(context, '/');
    } else {
      _teacherPasswordController.clear();
    }
  }

  @override
  void dispose() {
    _pupilUsernameController.dispose();
    _pupilPasswordController.dispose();
    _teacherUsernameController.dispose();
    _teacherPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });
  }

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        _type = (online ? '' : 'offline');
      });
      if (_type == '') {
        // Show type select dialog
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context1) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context).pleaseSelect),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      // Selected pupil
                      Navigator.pop(context);
                      setState(() {
                        _type = 'pupil';
                      });
                    },
                    child: Text(AppLocalizations.of(context).pupil),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      // Selected teacher
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
      }
    });
  }

  Future<bool> get checkOnline async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            // Logo
            Container(
              height: 125.0,
              margin: EdgeInsets.only(bottom: 5.0),
              child: SvgPicture.asset(
                'assets/images/logo.svg',
              ),
            ),
            // App name
            Center(
              child: Text(
                AppLocalizations.of(context).title,
                style: TextStyle(fontSize: 25),
              ),
            ),
            (_type == ''
                ? Container()
                : (_type == 'offline'
                    ?
                    // Show offline info
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                  AppLocalizations.of(context).goOnlineToLogin),
                              FlatButton(
                                color: Theme.of(context).accentColor,
                                child: Text(AppLocalizations.of(context).retry),
                                onPressed: () async {
                                  prepareLogin();
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    : (_type == 'pupil'
                        ?
                        // Show pupil login
                        Form(
                            key: _pupilFormKey,
                            child: Column(
                              children: <Widget>[
                                // Grade selector
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
                                // Username input
                                TextFormField(
                                  controller: _pupilUsernameController,
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
                                      hintText: AppLocalizations.of(context)
                                          .pupilUsername),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_pupilFocus);
                                  },
                                ),
                                // Password input
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
                                      hintText: AppLocalizations.of(context)
                                          .pupilPassword),
                                  onFieldSubmitted: (value) {
                                    checkPupilForm();
                                  },
                                  obscureText: true,
                                  focusNode: _pupilFocus,
                                ),
                                // Login button
                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      onPressed: () {
                                        checkPupilForm();
                                      },
                                      child: Text(
                                          AppLocalizations.of(context).login),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        :
                        // Show teacher login
                        Form(
                            key: _teacherFormKey,
                            child: Column(
                              children: <Widget>[
                                // Username input
                                TextFormField(
                                  controller: _teacherUsernameController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!_teacherCredentialsCorrect) {
                                      return AppLocalizations.of(context)
                                          .credentialsNotCorrect;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .teacherUsername),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_teacherFocus);
                                  },
                                ),
                                // Password input
                                TextFormField(
                                  controller: _teacherPasswordController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!_teacherCredentialsCorrect) {
                                      return AppLocalizations.of(context)
                                          .credentialsNotCorrect;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .teacherPassword),
                                  onFieldSubmitted: (value) {
                                    checkTeacherForm();
                                  },
                                  obscureText: true,
                                  focusNode: _teacherFocus,
                                ),
                                // Login button
                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      onPressed: () {
                                        checkTeacherForm();
                                      },
                                      child: Text(
                                          AppLocalizations.of(context).login),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )))),
          ],
        ),
      ),
    );
  }
}
