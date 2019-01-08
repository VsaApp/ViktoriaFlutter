import 'package:flutter/material.dart';
import 'LoadingPage.dart';

class LoadingPageView extends LoadingPageState {
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
