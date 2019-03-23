import 'package:flutter/material.dart';

import '../../Keys.dart';
import '../../Storage.dart';
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
      showDialog1 = Storage.getBool(Keys.showShortCutDialog) ?? true;
    });
    super.initState();
  }
}
