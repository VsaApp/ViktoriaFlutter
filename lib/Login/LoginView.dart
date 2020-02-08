import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'LoginPage.dart';

// ignore: public_member_api_docs
class LoginPageView extends LoginPageState {
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });
  }

  /// Checks if the app is online
  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            // Logo
            Container(
              height: 125,
              margin: EdgeInsets.only(bottom: 5),
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
            if (online != 1)
              // Show offline info
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(online == 0
                          ? AppLocalizations.of(context).failedToConnectToServer
                          : AppLocalizations.of(context).goOnlineToLogin),
                      FlatButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () async {
                          prepareLogin();
                        },
                        child: Text(AppLocalizations.of(context).retry),
                      )
                    ],
                  ),
                ),
              )
            else
              // Show pupil login
              Form(
                key: loginFormKey,
                child: Column(
                  children: <Widget>[
                    // Username input
                    TextFormField(
                      controller: usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).fieldCantBeEmpty;
                        }
                        if (!credentialsCorrect) {
                          return AppLocalizations.of(context)
                              .credentialsNotCorrect;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).pupilUsername),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(passwordFocus);
                      },
                    ),
                    // Password input
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).fieldCantBeEmpty;
                        }
                        if (!credentialsCorrect) {
                          return AppLocalizations.of(context)
                              .credentialsNotCorrect;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).pupilPassword),
                      onFieldSubmitted: (value) {
                        checkForm();
                      },
                      obscureText: true,
                      focusNode: passwordFocus,
                    ),
                    // Login button
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: checkForm,
                            child: !isCheckingForm
                                ? Text(AppLocalizations.of(context).login)
                                : Padding(
                                    padding: EdgeInsets.all(0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 1,
                                    ),
                                  )),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
