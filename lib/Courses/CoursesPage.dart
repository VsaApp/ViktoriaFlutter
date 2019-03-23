import 'package:flutter/material.dart';

import '../Keys.dart';
import '../Storage.dart';
import '../UnitPlan/UnitPlanData.dart';
import 'CoursesView.dart';

class CoursesPage extends StatefulWidget {
  @override
  CoursesPageView createState() => CoursesPageView();
}

abstract class CoursesPageState extends State<CoursesPage> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future update() async {
    await download(Storage.getString(Keys.grade), false);
    setState(() => null);
  }

  @override
  void initState() {
    super.initState();
  }
}
