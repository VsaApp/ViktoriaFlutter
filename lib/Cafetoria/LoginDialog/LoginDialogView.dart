import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginDialogWidget.dart';
import '../../Localizations.dart';
import '../../Keys.dart';
import '../CafetoriaData.dart';

class LoginDialogView extends LoginDialogState {
  final formKey = GlobalKey<FormState>();
  final focus = FocusNode();
  bool credentialsCorrect = true;
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  // Check the login
  void checkForm() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    credentialsCorrect = await checkLogin(
        id: idController.text, password: passwordController.text);
    if (formKey.currentState.validate()) {
      // Save correct credentials
      sharedPreferences.setString(Keys.cafetoriaId, idController.text);
      sharedPreferences.setString(
          Keys.cafetoriaPassword, passwordController.text);
      sharedPreferences.commit();
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
          (!online
              ?
              // Offline information
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).goOnlineToLogin),
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
                            hintText:
                                AppLocalizations.of(context).cafetoriaId),
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
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              checkForm();
                            },
                            child: Text(AppLocalizations.of(context).login),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
        ],
      ),
    );
  }
}
