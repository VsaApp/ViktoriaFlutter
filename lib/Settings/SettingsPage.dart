import 'package:flutter/material.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Storage.dart';
import 'SettingsView.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageView();
  }
}

abstract class SettingsPageState extends State<SettingsPage> {
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
  List<String> replacementplanVerion;
  List<String> unitplanVerion;
  bool sortReplacementPlan = true;
  bool showReplacementPlanInUnitPlan = true;
  bool getReplacementPlanNotifications = true;
  bool showShortCutDialog = true;
  bool showWorkGroupsInUnitPlan = true;
  bool showCalendarInUnitPlan = true;
  bool showCafetoriaInUnitPlan = true;
  bool dev = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
      loadSettings();
    });
    super.initState();
  }

  // Load saved settings
  void loadSettings() async {
    setState(() {
      grade = Storage.get(Keys.grade) ?? '';
      dev = Storage.get(Keys.dev) ?? false;
      sortReplacementPlan = Storage.getBool(Keys.sortReplacementPlan) ?? true;
      showReplacementPlanInUnitPlan =
          Storage.getBool(Keys.showReplacementPlanInUnitPlan) ?? true;
      getReplacementPlanNotifications =
          Storage.getBool(Keys.getReplacementPlanNotifications) ?? true;
      showShortCutDialog = Storage.getBool(Keys.showShortCutDialog) ?? true;
      replacementplanVerion =
          Storage.getStringList(Keys.historyDate('replacementplan'));
      unitplanVerion = Storage.getStringList(Keys.historyDate('unitplan'));
      showWorkGroupsInUnitPlan =
          Storage.getBool(Keys.showWorkGroupsInUnitPlan) ?? true;
      showCalendarInUnitPlan =
          Storage.getBool(Keys.showCalendarInUnitPlan) ?? true;
      showCafetoriaInUnitPlan =
          Storage.getBool(Keys.showCafetoriaInUnitPlan) ?? true;
      replacementplanVerion =
          Storage.getStringList(Keys.historyDate('replacementplan'));
      unitplanVerion = Storage.getStringList(Keys.historyDate('unitplan'));
      pages = [
        AppLocalizations.of(context).unitPlan,
        AppLocalizations.of(context).replacementPlan,
        AppLocalizations
            .of(context)
            .notices,
        AppLocalizations.of(context).calendar,
        AppLocalizations.of(context).cafetoria,
        AppLocalizations.of(context).workGroups,
        AppLocalizations.of(context).courses
      ];
      page = pages[Storage.getInt(Keys.initialPage) ?? 0];
    });
  }
}
