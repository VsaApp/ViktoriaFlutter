import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

/// Show snackbar for update data
void dataUpdated(BuildContext context, bool successfully, String name) {
  print('Show snackbar');
  if (HomePageState.isInForeground) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: successfully ? 1400 : 3000),
        content: Text(successfully
            ? name + AppLocalizations.of(context).updated
            : name + AppLocalizations.of(context).updatedFailed),
        action: SnackBarAction(
          label: AppLocalizations.of(context).ok,
          onPressed: () {},
        ),
      ),
    );
  }
}
