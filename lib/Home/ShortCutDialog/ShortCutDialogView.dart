import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'ShortCutDialogWidget.dart';

class ShortCutDialogView extends ShortCutDialogState {
  @override
  Widget build(BuildContext context) {
    // Show the shortcut dialog
    return SimpleDialog(
        title: Text(AppLocalizations.of(context).whatDoFirst),
        children: <Widget>[
          Column(
              // List of clickable chips
              children: widget.items.map((item) {
            return GestureDetector(
              onTap: () {
                widget.selectItem(widget.items.indexOf(item));
              },
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Transform(
                    transform: Matrix4.identity()..scale(0.8),
                    child: Container(
                      margin: EdgeInsets.all(3.0),
                      child: Icon(item.icon),
                    ),
                  ),
                ),
                label: Text(item.title),
              ),
            );
          }).toList()),
          // Short cut option
          CheckboxListTile(
            value: showDialog1,
            onChanged: (value) {
              Storage.setBool(Keys.showShortCutDialog, value);
              setState(() {
                showDialog1 = value;
              });
            },
            title: Text(AppLocalizations.of(context).showShortCutDialog),
          ),
        ]);
  }
}
