import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../data/ReplacementPlan.dart' as ReplacementPlan;
import '../data/UnitPlan.dart' as UnitPlan;
import '../data/WorkGroups.dart' as WorkGroups;
import '../data/Calendar.dart' as Calendar;

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    });
    super.initState();
  }

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
          child: Image(image: AssetImage('assets/images/ginkgobewegt.gif')),
          height: 75.0,
          width: 75.0,
        ),
      ),
    );
  }
}
