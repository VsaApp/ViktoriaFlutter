import 'package:flutter/material.dart';

import 'IntroView.dart';
import 'Slide/SlideWidget.dart';

/// A sliding page to introduce the user to all app features
class IntroPage extends StatefulWidget {
  @override
  IntroPageView createState() => IntroPageView();
}

// ignore: public_member_api_docs
abstract class IntroPageState extends State<IntroPage> {
  /// List of all slides
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();
  }
}
