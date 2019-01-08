import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Localizations.dart';
import 'SettingsView.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageView();
  }
}

abstract class SettingsPageState extends State<SettingsPage> {
  SharedPreferences sharedPreferences;
  static List<String> grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];
  String grade = grades[0];
  List<String> pages = [];
  String page = '';
  bool sortReplacementPlan = true;
  bool showReplacementPlanInUnitPlan = true;
  bool getReplacementPlanNotifications = true;
  bool showShortCutDialog = true;

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  // Load saved settings
  void loadSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      grade = sharedPreferences.get(Keys.grade) ?? '';
      sortReplacementPlan =
          sharedPreferences.getBool(Keys.sortReplacementPlan) ?? true;
      showReplacementPlanInUnitPlan =
          sharedPreferences.getBool(Keys.showReplacementPlanInUnitPlan) ?? true;
      getReplacementPlanNotifications =
          sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
              true;
      showShortCutDialog =
          sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      pages = [
        AppLocalizations.of(context).unitPlan,
        AppLocalizations.of(context).replacementPlan,
        AppLocalizations.of(context).calendar,
        AppLocalizations.of(context).cafetoria,
        AppLocalizations.of(context).workGroups,
        AppLocalizations.of(context).courses
      ];
      page = pages[sharedPreferences.getInt(Keys.initialPage) ?? 0];
    });
  }
}
