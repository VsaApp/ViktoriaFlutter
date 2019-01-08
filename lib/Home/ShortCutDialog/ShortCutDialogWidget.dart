import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Keys.dart';
import '../HomePage.dart';
import 'ShortCutDialogView.dart';

class ShortCutDialog extends StatefulWidget {
  final List<DrawerItem> items;
  final Function selectItem;

  ShortCutDialog({Key key, @required this.items, @required this.selectItem})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ShortCutDialogView();
}

abstract class ShortCutDialogState extends State<ShortCutDialog> {
  SharedPreferences sharedPreferences;
  bool showDialog1 = true;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        showDialog1 =
            sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      });
    });
    super.initState();
  }
}
