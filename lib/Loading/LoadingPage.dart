import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Network.dart';

import '../Cafetoria/CafetoriaData.dart' as Cafetoria;
import '../Calendar/CalendarData.dart' as Calendar;
import '../Keys.dart';
import '../Localizations.dart';
import '../Messageboard/MessageboardData.dart' as Messageboard;
import '../ReplacementPlan/ReplacementPlanData.dart' as ReplacementPlan;
import '../Rooms/RoomsData.dart' as Rooms;
import '../Storage.dart';
import '../Subjects/SubjectsData.dart' as Subjects;
import '../Teachers/TeachersData.dart' as Teachers;
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../WorkGroups/WorkGroupsData.dart' as WorkGroups;
import '../Network.dart';
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  int allDownloadsCount = 11;
  int countCurrentDownloads = 11;
  double centerWidgetDimensions = 150;
  List<String> texts = [];
  bool showTexts = false;
  bool animationForward = true;
  Timer textTimer;
  Animation animation;
  AnimationController controller;
  Stopwatch stopwatch;
  bool loggedIn = true;

  @override
  void initState() {
    checkOnline.then((online) async {
      if (online == 1) {
        
      }
    });
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
      texts.add(AppLocalizations.of(context).checkLogin);
      texts.add(AppLocalizations.of(context).replacementPlan);
      texts.add(AppLocalizations.of(context).workGroups);
      texts.add(AppLocalizations.of(context).calendar);
      texts.add(AppLocalizations
          .of(context)
          .messageboard);
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

  void showOldAppDialog(String version) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context1) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).appTooOld, style: TextStyle(color: Theme.of(context).accentColor)),
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 20, right: 20), child: Text(AppLocalizations.of(context).oldApp.replaceAll('VERSION', version)))
          ]
        );
      }
    );
          
  }

  Future downloadAll() async {
    Map<String, String> oldData = json
        .decode(Storage.getString(Keys.updates) ?? '{}')
        .cast<String, String>();
    Map<String, String> newData = {};
    bool loggedIn = false;
    await download(() async {
      String _username = sha256.convert(utf8.encode(Storage.getString(Keys.username))).toString();
      String _password = sha256.convert(utf8.encode(Storage.getString(Keys.password))).toString();
      final response = await httpGet('/login/$_username/$_password/', auth: false);
      loggedIn = json.decode(response)['status'];
      if (!loggedIn) Navigator.of(context).pushReplacementNamed('/login');
    }, 1, AppLocalizations.of(context).checkLogin);
    if (!loggedIn) return;
    try {
      String raw = await fetchData('/updates');
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

    String appVersion = (await rootBundle.loadString('pubspec.yaml'))
      .split('\n')
      .where((line) => line.startsWith('version'))
      .toList()[0]
      .split(':')[1]
      .trim();
    if (int.parse(newData['app']) > int.parse(appVersion.split('+')[1])) {
      showOldAppDialog(appVersion);
      return;
    }

    download(Messageboard.download, 1, AppLocalizations.of(context).messageboard);
    print('Downloading ' + (newData.keys.map((key) => newData[key] != oldData[key]).where((a) => a).length).toString() + ' new files');
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
            update: oldData[key] != newData[key] || oldData['replacementplantoday'] != newData['replacementplantoday'] || oldData['replacementplantomorrow'] != newData['replacementplantomorrow'],
          );
          texts.remove(AppLocalizations.of(context).unitPlan);
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
