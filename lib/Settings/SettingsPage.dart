import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'SettingsView.dart';

/// Page with user settings
class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageView();
  }
}

// ignore: public_member_api_docs
abstract class SettingsPageState extends State<SettingsPage> {
  /// The grade of the user
  String grade = '5a';

  /// All shortcuts pages
  List<String> pages = [];

  /// The current shortcut page
  String page = '';

  // ignore: public_member_api_docs
  bool showSubstitutionPlanInTimetable = true;
  // ignore: public_member_api_docs
  bool getSubstitutionPlanNotifications = true;
  // ignore: public_member_api_docs
  bool showShortCutDialog = true;
  // ignore: public_member_api_docs
  bool showWorkGroupsInTimetable = true;
  // ignore: public_member_api_docs
  bool showCalendarInTimetable = true;
  // ignore: public_member_api_docs
  bool showCafetoriaInTimetable = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
      loadSettings();
    });
    super.initState();
  }

  /// Load saved settings
  Future<void> loadSettings() async {
    setState(() {
      grade = Storage.get(Keys.grade) ?? '';
      showSubstitutionPlanInTimetable =
          Storage.getBool(Keys.showSubstitutionPlanInTimetable) ?? true;
      getSubstitutionPlanNotifications =
          Storage.getBool(Keys.getSubstitutionPlanNotifications) ?? true;
      showShortCutDialog = Storage.getBool(Keys.showShortCutDialog) ?? false;
      showWorkGroupsInTimetable =
          Storage.getBool(Keys.showWorkGroupsInTimetable) ?? true;
      showCalendarInTimetable =
          Storage.getBool(Keys.showCalendarInTimetable) ?? true;
      showCafetoriaInTimetable =
          Storage.getBool(Keys.showCafetoriaInTimetable) ?? true;
      pages = [
        AppLocalizations.of(context).timetable,
        AppLocalizations.of(context).substitutionPlan,
        AppLocalizations.of(context).calendar,
        AppLocalizations.of(context).cafetoria,
        AppLocalizations.of(context).workGroups,
        AppLocalizations.of(context).courses
      ];
      page = pages[Storage.getInt(Keys.initialPage) ?? 0];
    });
  }
}
