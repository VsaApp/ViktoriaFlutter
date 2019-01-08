import 'dart:io';
import 'package:flutter/material.dart';
import 'LoginDialogView.dart';

class LoginDialog extends StatefulWidget {
  final Function onFinished;
  
  LoginDialog({Key key, this.onFinished}) : super(key: key);
  
  @override
  LoginDialogView createState() => LoginDialogView();
}

abstract class LoginDialogState extends State<LoginDialog> {
  bool online = true;
  
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
        this.online = online;
      });
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
}
