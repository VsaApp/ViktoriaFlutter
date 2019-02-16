import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Calendar/CalendarData.dart' as Calendar;
import '../Keys.dart';
import '../Messageboard/MessageboardData.dart' as Messageboard;
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage> {
  int countCurrentDownloads = 0;
  SharedPreferences instance;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      this.instance = instance;
      downloadAll();
    });
    super.initState();
  }

  onFinishedAll() {
    // After download show app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int storedVersion = instance.getInt(Keys.slidesVersion) ?? 0;
      int currentVersion = 1;
      if (currentVersion != storedVersion) {
        instance.setInt(Keys.slidesVersion, currentVersion);
        Navigator.of(context).pushReplacementNamed('/intro');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  // Download all data
  Future downloadAll() async {
    countCurrentDownloads = 4;
    download(() async {
      await UnitPlan.download(instance.getString(Keys.grade), false);
      await ReplacementPlan.load(UnitPlan.getUnitPlan(), false);
    }, onFinishedAll);
    download(WorkGroups.download, onFinishedAll);
    download(Calendar.download, onFinishedAll);
    download(Messageboard.download, onFinishedAll);
  }

  Future download(Function() process, Function() onFinishedAll) async {
    await process();
    countCurrentDownloads--;
    if (countCurrentDownloads == 0) onFinishedAll();
  }
}
