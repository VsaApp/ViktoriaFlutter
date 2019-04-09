import 'package:flutter/material.dart';

import 'CoursesView.dart';

class CoursesPage extends StatefulWidget {
  @override
  CoursesPageView createState() => CoursesPageView();
}

abstract class CoursesPageState extends State<CoursesPage> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
  }
}
