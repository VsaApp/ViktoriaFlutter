import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Home/HomePage.dart';
import 'Id.dart';
import 'Intro/IntroPage.dart';
import 'Keys.dart';
import 'Loading/LoadingPage.dart';
import 'Localizations.dart';
import 'Login/LoginPage.dart';
import 'Scan/ScanPage.dart';
import 'Storage.dart';

// This is the first functions which is called in the app...
void main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  await Storage.init();
  await Id.init();

  // Default init is the loading screen...
  String _initialRoute = '/';

  // Set default options
  if (Storage.get(Keys.sortReplacementPlan) == null ||
      Storage.get(Keys.showReplacementPlanInUnitPlan) == null ||
      Storage.get(Keys.getReplacementPlanNotifications) == null ||
      Storage.get(Keys.showWorkGroupsInUnitPlan) == null ||
      Storage.get(Keys.showCalendarInUnitPlan) == null ||
      Storage.get(Keys.showCafetoriaInUnitPlan) == null) {
    Storage.setBool(Keys.sortReplacementPlan, true);
    Storage.setBool(Keys.showReplacementPlanInUnitPlan, true);
    Storage.setBool(Keys.getReplacementPlanNotifications, true);
    Storage.setBool(Keys.showWorkGroupsInUnitPlan, false);
    Storage.setBool(Keys.showCalendarInUnitPlan, true);
    Storage.setBool(Keys.showCafetoriaInUnitPlan, false);
  }

  // Check if logged in
  if (Storage.get(Keys.grade) == null ||
      Storage.get(Keys.username) == null ||
      Storage.get(Keys.password) == null) {
    _initialRoute = '/login';
  }

  // Start the app...
  runApp(MaterialApp(
    title: 'VsaApp',
    // Set fontfamily and main colors...
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF67A744),
        accentColor: Color(0xFF5BC638),
        fontFamily: 'Ubuntu'),
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    // Our app only supports the german language...
    supportedLocales: [
      Locale('de'),
    ],
    initialRoute: _initialRoute,
    // Define three shortcuts for pages: loading, home and login...
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => LoadingPage(),
      '/home': (BuildContext context) => HomePage(),
      '/login': (BuildContext context) => LoginPage(),
      '/intro': (BuildContext context) => IntroPage(),
      '/scan': (BuildContext context) => ScanPage()
    },
  ));
}
