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
  int allDownloadsCount = 9;
  int countCurrentDownloads = 9;
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
    download(() async {
      await UnitPlan.download(instance.getString(Keys.grade), false);
      await ReplacementPlan.load(UnitPlan.getUnitPlan(), false);
    }, 2);
    download(WorkGroups.download, 1);
    download(Calendar.download, 1);
    download(Messageboard.download, 1);
    download(Subjects.download, 1);
    download(Rooms.download, 1);
    download(Teachers.download, 1);
    download(() async {
      Cafetoria.download(
        id: 'null',
        password: 'null',
      );
    }, 1);
  }

  Future download(Function() process, int count) async {
    await process();
    for (int i = 0; i < count; i++) {
      countCurrentDownloads--;
      setState(() {
        texts.removeAt(Random().nextInt(texts.length));
      });
    }
    if (countCurrentDownloads == 0) {
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int storedVersion = instance.getInt(Keys.slidesVersion) ?? 0;
        int currentVersion = 1;
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
