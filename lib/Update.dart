import 'package:flutter/material.dart';
import 'Localizations.dart';

void dataUpdated(BuildContext context, bool successfully, String name) {
  print("Show snackbar");
  Scaffold.of(context).showSnackBar(
    SnackBar(
      duration: Duration(milliseconds: successfully ?  1400 : 3000),
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