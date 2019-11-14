import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
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
  bool showDialog1 = true;

  @override
  void initState() {
    setState(() {
      showDialog1 = Storage.getBool(Keys.showShortCutDialog) ?? false;
    });
    super.initState();
  }
}
