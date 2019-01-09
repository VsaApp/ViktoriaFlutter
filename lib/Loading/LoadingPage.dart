import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import '../Calendar/CalendarData.dart' as Calendar;
import '../Messageboard/MessageboardData.dart' as Messageboard;
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    downloadAll().then((_) {
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    });
    super.initState();
  }

  // Download all data
  Future downloadAll() async {
    await UnitPlan.download();
    await ReplacementPlan.download(
        (await SharedPreferences.getInstance()).getString(Keys.grade));
    await WorkGroups.download();
    await Calendar.download();
    await Messageboard.download();
  }
}
