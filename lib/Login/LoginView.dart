import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../Localizations.dart';
import '../Network.dart';
import 'LoginPage.dart';

class LoginPageView extends LoginPageState {
  String type = '';

  @override
  void dispose() {
    pupilUsernameController.dispose();
    pupilPasswordController.dispose();
    teacherUsernameController.dispose();
    teacherPasswordController.dispose();
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
        type = (online ? '' : 'offline');
      });
      if (type == '') {
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
                        type = 'pupil';
                      });
                    },
                    child: Text(AppLocalizations.of(context).pupil),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      // Selected teacher
                      Navigator.pop(context);
                      setState(() {
                        type = 'teacher';
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
            (type == ''
                ? Container()
                : (type == 'offline'
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
                    : (type == 'pupil'
                        ?
                        // Show pupil login
                        Form(
                            key: pupilFormKey,
                            child: Column(
                              children: <Widget>[
                                // Grade selector
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isDense: true,
                                      items: LoginPageState.grades.map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      value: grade,
                                      onChanged: (grade) {
                                        setState(() {
                                          this.grade = grade;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // Username input
                                TextFormField(
                                  controller: pupilUsernameController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!pupilCredentialsCorrect) {
                                      return AppLocalizations.of(context)
                                          .credentialsNotCorrect;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .pupilUsername),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(pupilFocus);
                                  },
                                ),
                                // Password input
                                TextFormField(
                                  controller: pupilPasswordController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!pupilCredentialsCorrect) {
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
                                  focusNode: pupilFocus,
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
                            key: teacherFormKey,
                            child: Column(
                              children: <Widget>[
                                // Username input
                                TextFormField(
                                  controller: teacherUsernameController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!teacherCredentialsCorrect) {
                                      return AppLocalizations.of(context)
                                          .credentialsNotCorrect;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .teacherUsername),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(teacherFocus);
                                  },
                                ),
                                // Password input
                                TextFormField(
                                  controller: teacherPasswordController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .fieldCantBeEmpty;
                                    }
                                    if (!teacherCredentialsCorrect) {
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
                                  focusNode: teacherFocus,
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
