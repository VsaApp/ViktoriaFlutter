import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Network.dart';

import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Downloader/WorkGroupsData.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'WorkGroupsView.dart';

class WorkGroupsPage extends StatefulWidget {
  @override
  WorkGroupsPageView createState() => WorkGroupsPageView();
}

abstract class WorkGroupsPageState extends State<WorkGroupsPage> {
  WorkGroups data;

  Future update() async {
    bool successfully =
        await WorkGroupsData().download(context) == StatusCodes.success;
    dataUpdated(context, successfully, AppLocalizations.of(context).workGroups);
    data = Data.workGroups;
    if (mounted) setState(() => this.data = data);
  }

  @override
  void initState() {
    // Download data
    WorkGroupsData().download(context).then((_) {
      if (mounted)
        setState(() {
          this.data = Data.workGroups;
        });
    });
    super.initState();
  }
}
