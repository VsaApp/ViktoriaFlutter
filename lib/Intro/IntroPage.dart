import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

import 'IntroView.dart';

class IntroPage extends StatefulWidget {
  @override
  IntroPageView createState() => IntroPageView();
}

abstract class IntroPageState extends State<IntroPage> {
  List<Slide> slides = [];
}
