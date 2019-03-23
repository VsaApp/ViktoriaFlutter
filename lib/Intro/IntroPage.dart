import 'package:flutter/material.dart';

import 'IntroView.dart';
import 'Slide/SlideWidget.dart';

class IntroPage extends StatefulWidget {
  @override
  IntroPageView createState() => IntroPageView();
}

abstract class IntroPageState extends State<IntroPage> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();
  }
}
