import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'IntroView.dart';
import 'Slide/SlideWidget.dart';

class IntroPage extends StatefulWidget {
  @override
  IntroPageView createState() => IntroPageView();
}

abstract class IntroPageState extends State<IntroPage> {
  SharedPreferences sharedPreferences;
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
  }
}
