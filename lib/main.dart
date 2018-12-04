import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Localizations.dart';
import 'Color.dart';
import 'Keys.dart';
import 'views/Home.dart';
import 'views/Login.dart';
import 'views/Loading.dart';

void main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _initialRoute = '/';

  if (sharedPreferences.get(Keys.sortReplacementPlan) == null ||
      sharedPreferences.get(Keys.showReplacementPlanInUnitPlan) == null ||
      sharedPreferences.get(Keys.getReplacementPlanNotifications) == null){
    sharedPreferences.setBool(Keys.sortReplacementPlan, true);
    sharedPreferences.setBool(Keys.showReplacementPlanInUnitPlan, true);
    sharedPreferences.setBool(Keys.getReplacementPlanNotifications, true);
  }

  if (sharedPreferences.get(Keys.grade) == null ||
      sharedPreferences.get(Keys.username) == null ||
      sharedPreferences.get(Keys.password) == null ||
      sharedPreferences.get(Keys.isTeacher) == null) {
    _initialRoute = '/login';
  }

  runApp(MaterialApp(
    title: 'ViktoriaFlutter',
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: getColorHexFromStr('#67a744'),
      accentColor: getColorHexFromStr('#5bc638'),
      fontFamily: 'Ubuntu'
    ),
    localizationsDelegates: [
      const AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('de'),
    ],
    initialRoute: _initialRoute,
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => new LoadingPage(),
      '/home': (BuildContext context) => new HomePage(),
      '/login': (BuildContext context) => new LoginPage()
    },
  ));
}
