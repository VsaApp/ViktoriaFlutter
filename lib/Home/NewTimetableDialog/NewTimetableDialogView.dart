import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'NewTimetableDialogModel.dart';

// ignore: public_member_api_docs
class NewTimetableDialogDialogView extends NewTimetableDialogState {
  @override
  Widget build(BuildContext context) {
    // Show the shortcut dialog
    return SimpleDialog(
        title: Text(AppLocalizations.of(context).newTimetable,
            style: TextStyle(color: Theme.of(context).accentColor)),
        children: <Widget>[
          Column(children: [
            Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 0),
                child: Center(
                    child: Text(AppLocalizations.of(context).newTimetableInfo))),
            FlatButton(
              onPressed: Navigator.of(context).pop,
              child: Text(AppLocalizations.of(context).ok,
                  style: TextStyle(color: Theme.of(context).accentColor)),
            )
          ])
        ]);
  }
}
