import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'WorkGroupsData.dart';
import 'WorkGroupsModel.dart';
import 'WorkGroupsView.dart';

class WorkGroupsPage extends StatefulWidget {
  @override
  WorkGroupsPageView createState() => WorkGroupsPageView();
}

abstract class WorkGroupsPageState extends State<WorkGroupsPage> {
  WorkGroups data;

  Future update() async {
    data = await download(onFinished: (successfully) {
      dataUpdated(context, successfully, AppLocalizations.of(context).workGroups);
    });
    setState(() => this.data = data);
  }

  @override
  void initState() {
    // Download data
    download().then((data) {
      if (mounted) setState(() {
        this.data = data;
      });
    });
    super.initState();
  }
}
