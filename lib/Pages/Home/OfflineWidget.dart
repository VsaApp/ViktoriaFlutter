import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';

/// Shows a snackbar to inform the user that he is offline
class OfflineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkOnline.then((online) {
      if (online != 1 && MainFrameState.isInForeground) {
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
