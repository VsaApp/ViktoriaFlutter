import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Cafetoria/CafetoriaData.dart' as Cafetoria;
import '../Calendar/CalendarData.dart' as Calendar;
import '../Keys.dart';
import '../Localizations.dart';
import '../Messageboard/MessageboardData.dart' as Messageboard;
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../Rooms/RoomsData.dart' as Rooms;
import '../Subjects/SubjectsData.dart' as Subjects;
import '../Teachers/TeachersData.dart' as Teachers;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage> {
  int allDownloadsCount = 0;
  int countCurrentDownloads;
  SharedPreferences instance;
  List<String> texts = [];

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      this.instance = instance;
      texts.add(AppLocalizations.of(context).unitPlan);
      texts.add(AppLocalizations.of(context).replacementPlan);
      texts.add(AppLocalizations.of(context).workGroups);
      texts.add(AppLocalizations.of(context).calendar);
      texts.add(AppLocalizations.of(context).messageboard);
      texts.add(AppLocalizations.of(context).subjects);
      texts.add(AppLocalizations.of(context).rooms);
      texts.add(AppLocalizations.of(context).teachers);
      texts.add(AppLocalizations.of(context).cafetoria);
      texts.shuffle();
      downloadAll();
    });
    super.initState();
  }

  // Download all data
  Future downloadAll() async {
    allDownloadsCount = 9;
    countCurrentDownloads = allDownloadsCount;
    download(() async {
      await UnitPlan.download(instance.getString(Keys.grade), false);
      texts.remove(AppLocalizations.of(context).unitPlan);
      await ReplacementPlan.load(UnitPlan.getUnitPlan(), false);
    }, 2, AppLocalizations.of(context).replacementPlan);
    download(WorkGroups.download, 1, AppLocalizations.of(context).workGroups);
    download(Calendar.download, 1, AppLocalizations.of(context).calendar);
    download(Messageboard.download, 1, AppLocalizations.of(context).messageboard);
    download(Subjects.download, 1, AppLocalizations.of(context).subjects);
    download(Rooms.download, 1, AppLocalizations.of(context).rooms);
    download(Teachers.download, 1, AppLocalizations.of(context).teachers);
    download(() async {
      Cafetoria.download(
        id: 'null',
        password: 'null',
      );
    }, 1, AppLocalizations.of(context).cafetoria);
  }

  Future download(Function() process, int count, String text) async {
    await process();
    for (int i = 0; i < count; i++) {
      countCurrentDownloads--;
      setState(() {
        texts.remove(text);
      });
    }
    if (countCurrentDownloads == 0) {
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int storedVersion = instance.getInt(Keys.slidesVersion) ?? 0;
        int currentVersion = 3;
        if (currentVersion != storedVersion) {
          instance.setInt(Keys.slidesVersion, currentVersion);
          Navigator.of(context).pushReplacementNamed('/intro');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }
}
