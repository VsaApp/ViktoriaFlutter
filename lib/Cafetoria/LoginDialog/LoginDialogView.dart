import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Downloader/CafetoriaData.dart';
import 'LoginDialogWidget.dart';

class LoginDialogView extends LoginDialogState {
  final formKey = GlobalKey<FormState>();
  final focus = FocusNode();
  bool credentialsCorrect = true;

  // Check the login
  void checkForm() async {
    credentialsCorrect = await CafetoriaData()
        .checkLogin(id: idController.text, password: passwordController.text);
    if (formKey.currentState.validate()) {
      // Save correct credentials
      Storage.setString(Keys.cafetoriaId, idController.text);
      Storage.setString(Keys.cafetoriaPassword, passwordController.text);
      syncTags(syncExams: false, syncSelections: false);
      Navigator.pop(context);
      // Update UI
      widget.onFinished();
    } else {
      passwordController.clear();
    }
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          (online != 1
              ?
              // Offline information
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(online == -1
                            ? AppLocalizations.of(context).goOnlineToLogin
                            : AppLocalizations.of(context)
                                .failedToConnectToServer),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(AppLocalizations.of(context).retry),
                          onPressed: () async {
                            // Retry
                            prepareLogin();
                          },
                        )
                      ],
                    ),
                  ),
                )
              :
              // Show form
              Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      // ID input
                      TextFormField(
                        controller: idController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)
                                .fieldCantBeEmpty;
                          }
                          if (!credentialsCorrect) {
                            return AppLocalizations.of(context)
                                .credentialsNotCorrect;
                          }
                        },
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).cafetoriaId),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(focus);
                        },
                      ),
                      // Pin input
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)
                                .fieldCantBeEmpty;
                          }
                          if (!credentialsCorrect) {
                            return AppLocalizations.of(context)
                                .credentialsNotCorrect;
                          }
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).cafetoriaPassword),
                        onFieldSubmitted: (value) {
                          checkForm();
                        },
                        obscureText: true,
                        focusNode: focus,
                      ),
                      // Login button
                      Row(children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, right: 5),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                checkForm();
                              },
                              child: Text(AppLocalizations.of(context).login),
                            ),
                          )
                        ),
                        if (isLoggedIn) 
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10, left: 5),
                              child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  Storage.remove(Keys.cafetoriaId);
                                  Storage.remove(Keys.cafetoriaPassword);
                                  syncTags(syncExams: false, syncSelections: false);
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context).logout),
                              ),
                            )
                          ),
                        
                      ])
                    ],
                  ),
                ))
        ],
      ),
    );
  }
}
