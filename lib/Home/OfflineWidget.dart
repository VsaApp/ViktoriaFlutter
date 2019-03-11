import 'package:flutter/material.dart';

import '../Localizations.dart';
import '../Network.dart';

class OfflineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkOnline.then((online) {
      if (online != 1) {
        // Show offline information
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(online == -1
                ? AppLocalizations.of(context).oldDataIsShown
                : AppLocalizations.of(context).serverIsOffline),
            action: SnackBarAction(
              label: AppLocalizations.of(context).ok,
              onPressed: () {},
            ),
          ),
        );
      }
    });
    return Container();
  }
}
