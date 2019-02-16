import 'package:flutter/material.dart';

import 'LoadingPage.dart';

class LoadingPageView extends LoadingPageState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: CircularProgressIndicator(strokeWidth: 5.0),
          height: 75.0,
          width: 75.0,
        ),
      ),
    );
  }
}
