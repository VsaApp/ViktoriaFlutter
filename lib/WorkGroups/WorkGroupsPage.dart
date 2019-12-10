import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Network.dart';

import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Downloader/WorkGroupsData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'WorkGroupsView.dart';

/// Page with a list of all work groups
class WorkGroupsPage extends StatefulWidget {
  @override
  WorkGroupsPageView createState() => WorkGroupsPageView();
}

// ignore: public_member_api_docs
abstract class WorkGroupsPageState extends State<WorkGroupsPage> {
  // ignore: public_member_api_docs
  WorkGroups data;

  /// Updates the work groups
  Future update() async {
    final bool successfully =
        await WorkGroupsData().download(context) == StatusCodes.success;
    dataUpdated(context, successfully, AppLocalizations.of(context).workGroups);
    data = Data.workGroups;
    if (mounted) {
      setState(() => null);
    }
  }

  @override
  void initState() {
    // Download data
    WorkGroupsData().download(context).then((_) {
      if (mounted) {
        setState(() {
          data = Data.workGroups;
        });
      }
    });
    super.initState();
  }
}
