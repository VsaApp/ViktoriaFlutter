import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Color.dart';
import 'Keys.dart';
import 'Localizations.dart';
import 'views/Home.dart';
import 'views/Loading.dart';
import 'views/Login.dart';

// This is the first functions which is called in the app...
void main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Default init is the loading screen...
  String _initialRoute = '/';

  // Set must writing courses...
  sharedPreferences.setBool(Keys.exams('E'), true);
  sharedPreferences.setBool(Keys.exams('M'), true);
  sharedPreferences.setBool(Keys.exams('D'), true);
  sharedPreferences.setBool(Keys.exams('L'), true);
  sharedPreferences.setBool(Keys.exams('S'), true);
  sharedPreferences.setBool(Keys.exams('F'), true);
  sharedPreferences.commit();

  // Set default options
  if (sharedPreferences.get(Keys.sortReplacementPlan) == null ||
      sharedPreferences.get(Keys.showReplacementPlanInUnitPlan) == null ||
      sharedPreferences.get(Keys.getReplacementPlanNotifications) == null) {
    sharedPreferences.setBool(Keys.sortReplacementPlan, true);
    sharedPreferences.setBool(Keys.showReplacementPlanInUnitPlan, true);
    sharedPreferences.setBool(Keys.getReplacementPlanNotifications, true);
  }

  // Check if logged in
  if (sharedPreferences.get(Keys.grade) == null ||
      sharedPreferences.get(Keys.username) == null ||
      sharedPreferences.get(Keys.password) == null ||
      sharedPreferences.get(Keys.isTeacher) == null) {
    _initialRoute = '/login';
  }

  // Start the app...
  runApp(MaterialApp(
    title: 'ViktoriaFlutter',
    // Set fontfamily and main colors...
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: getColorHexFromStr('#67a744'),
        accentColor: getColorHexFromStr('#5bc638'),
        fontFamily: 'Ubuntu'),
    localizationsDelegates: [
      const AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    // Our app only supports the german language...
    supportedLocales: [
      const Locale('de'),
    ],
    initialRoute: _initialRoute,
    // Define three shortcuts for pages: loading, home and login...
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => new LoadingPage(),
      '/home': (BuildContext context) => new HomePage(),
      '/login': (BuildContext context) => new LoginPage()
    },
  ));
}
