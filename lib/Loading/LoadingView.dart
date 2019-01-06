import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import '../Calendar/CalendarData.dart' as Calendar;

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadingPageState();
  }
}

class LoadingPageState extends State<LoadingPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          // Funny loader
          child: Image(image: AssetImage('assets/images/ginkgobewegt.gif')),
          height: 75.0,
          width: 75.0,
        ),
      ),
    );
  }
}
