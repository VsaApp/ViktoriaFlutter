import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './NewUnitplanDialogView.dart';

class NewUnitplanDialog extends StatefulWidget {
  NewUnitplanDialog({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewUnitplanDialogDialogView();
}

abstract class NewUnitplanDialogState extends State<NewUnitplanDialog> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    super.initState();
  }
}
