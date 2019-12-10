import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import 'LoginDialogView.dart';

/// Login dialog for the keyfob login data
class LoginDialog extends StatefulWidget {
  /// Finished login callback
  final Function onFinished;

  // ignore: public_member_api_docs
  const LoginDialog({Key key, this.onFinished}) : super(key: key);

  @override
  LoginDialogView createState() => LoginDialogView();
}

// ignore: public_member_api_docs
abstract class LoginDialogState extends State<LoginDialog> {
  /// Text editing controller for the keyfob id
  TextEditingController idController;

  /// Text editing controller for the keyfob password
  TextEditingController passwordController;

  /// Login status
  bool isLoggedIn = false;

  /// Online status
  int online = 1;

  @override
  void initState() {
    isLoggedIn = Storage.getString(Keys.cafetoriaPassword) != null;
    idController =
        TextEditingController(text: Storage.getString(Keys.cafetoriaId));
    passwordController = TextEditingController();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });
  }

  /// Checks if the device is online
  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }
}
