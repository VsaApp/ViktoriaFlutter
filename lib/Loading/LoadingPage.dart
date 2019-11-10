import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Errors.dart' as bugs;

import '../Cafetoria/CafetoriaData.dart' as Cafetoria;
import '../Calendar/CalendarData.dart' as Calendar;
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../SubstitutionPlan/SubstitutionPlanData.dart' as SubstitutionPlan;
import '../Rooms/RoomsData.dart' as Rooms;
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../Subjects/SubjectsData.dart' as Subjects;
import '../Teachers/TeachersData.dart' as Teachers;
import '../Timetable/TimetableData.dart' as Timetable;
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
  bool animationForward = true;
  Timer textTimer;
  Animation animation;
  AnimationController controller;
  Stopwatch stopwatch;
  bool loggedIn = true;

  @override
  void initState() {
    () async {
      await Storage.init();
      bugs.init();

      // Set default options
      if (Storage.get(Keys.sortSubstitutionPlan) == null ||
          Storage.get(Keys.showSubstitutionPlanInTimetable) == null ||
          Storage.get(Keys.getSubstitutionPlanNotifications) == null ||
          Storage.get(Keys.showWorkGroupsInTimetable) == null ||
          Storage.get(Keys.showCalendarInTimetable) == null ||
          Storage.get(Keys.showCafetoriaInTimetable) == null) {
        Storage.setBool(Keys.sortSubstitutionPlan, true);
        Storage.setBool(Keys.showSubstitutionPlanInTimetable, true);
        Storage.setBool(Keys.getSubstitutionPlanNotifications, true);
        Storage.setBool(Keys.showWorkGroupsInTimetable, false);
        Storage.setBool(Keys.showCalendarInTimetable, true);
        Storage.setBool(Keys.showCafetoriaInTimetable, false);
      }

      // Check if logged in
      if (Storage.get(Keys.username) == null ||
          Storage.get(Keys.password) == null) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
      }

      checkOnline.then((online) async {
        if (online == 1) {}
      });

      WidgetsBinding.instance.addPostFrameCallback((a) {
        if (Platform.isAndroid) {
          MethodChannel('viktoriaflutter').invokeMethod('applyTheme', {
            'color': Theme
                .of(context)
                .primaryColor
                .value
                .toRadixString(16)
                .substring(2)
                .toUpperCase(),
          });
        }
        texts.add(AppLocalizations
            .of(context)
            .updates);
        texts.add(AppLocalizations.of(context).timetable);
        texts.add(AppLocalizations.of(context).substitutionPlan);
        texts.add(AppLocalizations.of(context).workGroups);
        texts.add(AppLocalizations.of(context).calendar);
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
    }();
    super.initState();
  }

  @override
  void dispose() {
    if (textTimer != null) textTimer.cancel();
    if (controller != null) controller.dispose();
    super.dispose();
  }

  void showOldAppDialog(String version) {
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context1) {
          return SimpleDialog(
              title: Text(AppLocalizations
                  .of(context)
                  .appTooOld,
                  style: TextStyle(color: Theme
                      .of(context)
                      .accentColor)),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(AppLocalizations
                        .of(context)
                        .oldApp
                        .replaceAll('VERSION', version)))
              ]);
        });
  }

  Future downloadAll() async {
    stopwatch = Stopwatch()
      ..start();

    Map<String, String> currentData = json
        .decode(Storage.getString(Keys.updates) ?? '{}')
        .cast<String, String>();
    Map<String, String> newData = {};
    try {
      final raw = await fetch('/updates');
      if (raw == null) throw 'Updates response is undefined';
      if (raw.statusCode == 401) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      newData = json.decode(raw.body).cast<String, String>();
    } catch (e) {
      newData = currentData;
    }
    String oldGrade = Storage.getString(Keys.grade) ?? '--';
    String newGrade = newData['grade'];
    Storage.setString(Keys.oldGrade, newGrade);
    
    setState(() {
      countCurrentDownloads--;
      texts.remove(AppLocalizations
          .of(context)
          .updates);
    });

    String appVersion = (await rootBundle.loadString('pubspec.yaml'))
        .split('\n')
        .where((line) => line.startsWith('version'))
        .toList()[0]
        .split(':')[1]
        .trim();
    if (int.parse(newData['minAppLevel']) > int.parse(appVersion.split('+')[1])) {
      showOldAppDialog(appVersion);
      return;
    }

    print('Downloading ' +
        (newData.keys
            .map((key) =>
        newData[key] != currentData[key] || oldGrade != newGrade)
            .where((a) => a)
            .length)
            .toString() +
        ' new files');
    newData.keys.forEach((key) {
      if (key == 'subjectsDef') {
        download(() async {
          await Subjects.download(
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .subjects);
      } else if (key == 'roomsDef') {
        download(() async {
          await Rooms.download(
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .rooms);
      } else if (key == 'teachersDef') {
        download(() async {
          await Teachers.download(
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .teachers);
      } else if (key == 'cafetoria') {
        download(() async {
          await Cafetoria.download(
            id: 'null',
            password: 'null',
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .cafetoria);
      } else if (key == 'calendar') {
        download(() async {
          await Calendar.download(
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .calendar);
      } else if (key == 'timetable') {
        download(() async {
          await Timetable.download(
            Storage.getString(Keys.grade),
            false,
            update: currentData[key] != newData[key] ||
                currentData['substitutionPlantoday'] !=
                    newData['substitutionPlantoday'] ||
                currentData['substitutionPlantomorrow'] !=
                    newData['substitutionPlantomorrow'] ||
                oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                currentData['substitutionPlantoday'] = newData['substitutionPlantoday'];
                currentData['substitutionPlantomorrow'] = newData['substitutionPlantomorrow'];
              }
            }
          );
          texts.remove(AppLocalizations.of(context).timetable);
          SubstitutionPlan.load(Timetable.getTimetable(), false);
        }, 2, AppLocalizations
            .of(context)
            .substitutionPlan);
      } else if (key == 'workgroups') {
        download(() async {
          await WorkGroups.download(
            update: currentData[key] != newData[key] || oldGrade != newGrade,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData[key] = newData[key];
                Storage.setString(Keys.updates, json.encode(currentData));
              }
            }
          );
        }, 1, AppLocalizations
            .of(context)
            .workGroups);
      }
      else if (key != 'substitutionPlantoday' && key != 'substitutionPlantomorrow') currentData[key] = newData[key];
      if (currentData[key] != newData[key] || oldGrade != newGrade) {
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
      stopwatch.stop();
      print(stopwatch.elapsedMilliseconds);
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
