import 'package:flutter/material.dart';
import './NewUnitplanDialogModel.dart';
import '../../Localizations.dart';
import '../../Keys.dart';

class NewUnitplanDialogDialogView extends NewUnitplanDialogState {
  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    // Show the shortcut dialog
    return SimpleDialog(
        title: Text(AppLocalizations.of(context).newUnitplan, style: TextStyle(color: Theme.of(context).accentColor)),
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 0),
                child:  Center(
                  child: Text(AppLocalizations.of(context).newUnitplanInfo)
                )
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).ok, style: TextStyle(color: Theme.of(context).accentColor)),
                onPressed: Navigator.of(context).pop,
              )
            ]
          )
        ]
    );
  }
}
