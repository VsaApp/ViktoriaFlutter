import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../HomePage.dart';
import 'ShortCutDialogView.dart';

/// A dialog with shortcuts to all features
class ShortCutDialog extends StatefulWidget {
  /// All drawer items to jump to
  final List<DrawerItem> items;

  /// The selected item callback
  final void Function(int) selectItem;

  // ignore: public_member_api_docs
  const ShortCutDialog({@required this.items, @required this.selectItem, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ShortCutDialogView();
}

// ignore: public_member_api_docs
abstract class ShortCutDialogState extends State<ShortCutDialog> {
  /// Sets if the shortcut dialog should be shown
  bool showShortCutDialog = true;

  @override
  void initState() {
    setState(() {
      showShortCutDialog = Storage.getBool(Keys.showShortCutDialog) ?? false;
    });
    super.initState();
  }
}
