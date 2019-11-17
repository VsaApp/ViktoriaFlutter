import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'LoginDialogView.dart';

class LoginDialog extends StatefulWidget {
  final Function onFinished;

  LoginDialog({Key key, this.onFinished}) : super(key: key);

  @override
  LoginDialogView createState() => LoginDialogView();
}

abstract class LoginDialogState extends State<LoginDialog> {
  TextEditingController idController;
  TextEditingController passwordController;
  bool isLoggedIn = false;
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

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }
}
