import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Network.dart';

import '../Cafetoria/CafetoriaData.dart' as Cafetoria;
import '../Calendar/CalendarData.dart' as Calendar;
import '../Keys.dart';
import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../Rooms/RoomsData.dart' as Rooms;
import '../Storage.dart';
import '../Subjects/SubjectsData.dart' as Subjects;
import '../Teachers/TeachersData.dart' as Teachers;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  int allDownloadsCount = 9;
  int countCurrentDownloads = 9;
  double centerWidgetDimensions = 150;
  List<String> texts = [];
  bool showTexts = false;
  bool showLogo = false;
  bool animationForward = true;
  Timer textTimer;
  Animation animation;
  AnimationController controller;
  Stopwatch stopwatch;
  bool loggedIn = true;

  @override
  void initState() {
    // Check if logged in
    if (Storage.get(Keys.grade) == null ||
        Storage.get(Keys.username) == null ||
        Storage.get(Keys.password) == null) {
      setState(() => loggedIn = false);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((a) {
      texts.add(AppLocalizations
          .of(context)
          .updates);
      texts.add(AppLocalizations.of(context).unitPlan);
      texts.add(AppLocalizations.of(context).replacementPlan);
      texts.add(AppLocalizations.of(context).workGroups);
      texts.add(AppLocalizations.of(context).calendar);
      //texts.add(AppLocalizations.of(context).messageboard);
      texts.add(AppLocalizations.of(context).subjects);
      texts.add(AppLocalizations.of(context).rooms);
      texts.add(AppLocalizations.of(context).teachers);
      texts.add(AppLocalizations.of(context).cafetoria);
      texts.shuffle();
      downloadAll();
    });
    textTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        showTexts = true;
      });
    });
    controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    setState(() {
      animation = Tween<double>(begin: -0.01, end: 0.01).animate(controller)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            controller.forward();
          }
        });
      controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    textTimer.cancel();
    controller.dispose();
    super.dispose();
  }

  Future downloadAll() async {
    Map<String, String> oldData =
        json.decode(Storage.getString(Keys.updates)).cast<String, String>() ??
            {};
    Map<String, String> newData = {};
    try {
      String raw = await fetchData('https://api.vsa.2bad2c0.de/updates');
      newData = json.decode(raw).cast<String, String>();
      Storage.setString(Keys.updates, raw);
    } catch (e) {
      print(e);
      newData = oldData;
    }
    setState(() {
      countCurrentDownloads--;
      texts.remove(AppLocalizations
          .of(context)
          .updates);
      stopwatch = Stopwatch()
        ..start();
    });

    /*download(
        Messageboard.download, 1, AppLocalizations.of(context).messageboard);*/
    print('Downloading ' +
        (newData.keys
            .map((key) => newData[key] != oldData[key])
            .where((a) => a)
            .length)
            .toString() +
        ' new files');
    if (newData.keys
        .map((key) => newData[key] != oldData[key])
        .where((a) => a)
        .length >
        0) {
      setState(() {
        showLogo = true;
      });
    }
    newData.keys.forEach((key) {
      if (key == 'subjectsDef') {
        download(() async {
          await Subjects.download(
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .subjects);
      } else if (key == 'roomsDef') {
        download(() async {
          await Rooms.download(
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .rooms);
      } else if (key == 'teachersDef') {
        download(() async {
          await Teachers.download(
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .teachers);
      } else if (key == 'cafetoria') {
        download(() async {
          await Cafetoria.download(
            id: 'null',
            password: 'null',
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .cafetoria);
      } else if (key == 'calendar') {
        download(() async {
          await Calendar.download(
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .calendar);
      } else if (key == 'unitplan') {
        download(() async {
          await UnitPlan.download(
            Storage.getString(Keys.grade),
            false,
            update: oldData[key] != newData[key],
          );
          texts.remove(AppLocalizations
              .of(context)
              .unitPlan);
          ReplacementPlan.load(UnitPlan.getUnitPlan(), false);
        }, 2, AppLocalizations
            .of(context)
            .replacementPlan);
      } else if (key == 'workgroups') {
        download(() async {
          await WorkGroups.download(
            update: oldData[key] != newData[key],
          );
        }, 1, AppLocalizations
            .of(context)
            .workGroups);
      }
      if (oldData[key] != newData[key]) {
        print('Downloading ' + key);
      }
    });
  }

  Future download(Function() process, int count, String text) async {
    await process();
    for (int i = 0; i < count; i++) {
      countCurrentDownloads--;
    }
    setState(() {
      texts.remove(text);
    });
    if (countCurrentDownloads == 0) {
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int storedVersion = Storage.getInt(Keys.slidesVersion) ?? 0;
        int currentVersion = 3;
        if (currentVersion != storedVersion) {
          Storage.setInt(Keys.slidesVersion, currentVersion);
          Navigator.of(context).pushReplacementNamed('/intro');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }
}
