import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UnitPlan/UnitPlanData.dart';
import '../Keys.dart';
import 'CoursesView.dart';
import '../Keys.dart';

class CoursesPage extends StatefulWidget {
  @override
  CoursesPageView createState() => CoursesPageView();
}

abstract class CoursesPageState extends State<CoursesPage> {
  SharedPreferences sharedPreferences;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future update() async {
    await download(sharedPreferences.getString(Keys.grade), false);
    setState(() => null);
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    super.initState();
  }
}
