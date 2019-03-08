import 'package:flutter/material.dart';

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
    data = await download();
    setState(() => this.data = data);
  }

  @override
  void initState() {
    // Download data
    download().then((data) {
      setState(() {
        this.data = data;
      });
    });
    super.initState();
  }
}
