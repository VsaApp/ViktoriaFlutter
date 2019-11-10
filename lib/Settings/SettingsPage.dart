import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
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
  List<String> substitutionPlanVersion;
  List<String> timetableVersion;
  bool sortSubstitutionPlan = true;
  bool showSubstitutionPlanInTimetable = true;
  bool getSubstitutionPlanNotifications = true;
  bool showShortCutDialog = true;
  bool showWorkGroupsInTimetable = true;
  bool showCalendarInTimetable = true;
  bool showCafetoriaInTimetable = true;
  bool muteDevice = false;
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
      sortSubstitutionPlan = Storage.getBool(Keys.sortSubstitutionPlan) ?? true;
      showSubstitutionPlanInTimetable =
          Storage.getBool(Keys.showSubstitutionPlanInTimetable) ?? true;
      getSubstitutionPlanNotifications =
          Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true;
      showShortCutDialog = Storage.getBool(Keys.showShortCutDialog) ?? true;
      substitutionPlanVersion =
          Storage.getStringList(Keys.historyDate('substitutionPlan'));
      timetableVersion = Storage.getStringList(Keys.historyDate('timetable'));
      showWorkGroupsInTimetable =
          Storage.getBool(Keys.showWorkGroupsInTimetable) ?? true;
      showCalendarInTimetable =
          Storage.getBool(Keys.showCalendarInTimetable) ?? true;
      showCafetoriaInTimetable =
          Storage.getBool(Keys.showCafetoriaInTimetable) ?? true;
      substitutionPlanVersion =
          Storage.getStringList(Keys.historyDate('substitutionPlan'));
      timetableVersion = Storage.getStringList(Keys.historyDate('timetable'));
      pages = [
        AppLocalizations.of(context).timetable,
        AppLocalizations.of(context).substitutionPlan,
        AppLocalizations.of(context).calendar,
        AppLocalizations.of(context).cafetoria,
        AppLocalizations.of(context).workGroups,
        AppLocalizations.of(context).courses
      ];
      muteDevice = Storage.getBool(Keys.muteService);
      page = pages[Storage.getInt(Keys.initialPage) ?? 0];
    });
  }
}
