import 'dart:async';
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
import '../Updates/UpdatesData.dart' as Updates;
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
            'color': Theme.of(context)
                .primaryColor
                .value
                .toRadixString(16)
                .substring(2)
                .toUpperCase(),
          });
        }
        texts.add(AppLocalizations.of(context).updates);
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
        animation = Tween<double>(begin: -0.0, end: 0.01).animate(controller)
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
              title: Text(AppLocalizations.of(context).appTooOld,
                  style: TextStyle(color: Theme.of(context).accentColor)),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(AppLocalizations.of(context)
                        .oldApp
                        .replaceAll('VERSION', version)))
              ]);
        });
  }

  Future downloadAll() async {
    stopwatch = Stopwatch()..start();

    // Get current versions of local data
    final currentData = Updates.getUpdates(loaded: false);

    // Get the versions of server data
    final completer = Completer<int>();
    final newData = await Updates.download(onFinished: completer.complete);
    if (await completer.future == 401) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    String oldGrade = Storage.getString(Keys.grade) ?? '--';
    String newGrade = newData.grade;
    bool gradeChanged = newGrade != oldGrade;
    Storage.setString(Keys.grade, newGrade);

    // Download updates finished
    setState(() {
      countCurrentDownloads--;
      texts.remove(AppLocalizations.of(context).updates);
    });

    // Get the current app version to check the min app level
    String appVersion = (await rootBundle.loadString('pubspec.yaml'))
        .split('\n')
        .where((line) => line.startsWith('version'))
        .toList()[0]
        .split(':')[1]
        .trim();
    if (newData.minAppLevel > int.parse(appVersion.split('+')[1])) {
      showOldAppDialog(appVersion);
      return;
    }

    // Print all data to download
    Map<String, dynamic> newDataMap = newData.toMap();
    Map<String, dynamic> currentDataMap = currentData.toMap();
    print('Downloading ' +
        (newDataMap.keys
                .map((key) =>
                    newDataMap[key] != currentDataMap[key] || gradeChanged)
                .where((a) => a)
                .length)
            .toString() +
        ' new files');

    // Download subjects, rooms, teachers, timetable and substitution plan in the correct order
    () async {
      // Update subjects
      await download(() async {
        await Subjects.download(
            update:
                updated(newData.subjects, currentData.subjects) || gradeChanged,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData.subjects = newData.subjects;
              }
            });
      }, AppLocalizations.of(context).subjects);

      // Update rooms
      await download(() async {
        await Rooms.download(
            update: updated(newData.rooms, currentData.rooms) || gradeChanged,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData.rooms = newData.rooms;
              }
            });
      }, AppLocalizations.of(context).rooms);

      // Update teachers
      await download(() async {
        await Teachers.download(
            update:
                updated(newData.teachers, currentData.teachers) || gradeChanged,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData.teachers = newData.teachers;
              }
            });
      }, AppLocalizations.of(context).teachers);

      // Update timetable
      await download(() async {
        await Timetable.download(false,
            update: updated(newData.timetable, currentData.timetable) ||
                gradeChanged, onFinished: (bool successfully) {
          if (successfully ?? true) {
            currentData.timetable = newData.timetable;
          }
        });
      }, AppLocalizations.of(context).timetable);

      // Update substitution plan
      await download(() async {
        await SubstitutionPlan.download(
            update: updated(
                    newData.substitutionPlan, currentData.substitutionPlan) ||
                gradeChanged,
            onFinished: (bool successfully) {
              if (successfully ?? true) {
                currentData.substitutionPlan = newData.substitutionPlan;
              }
            });
      }, AppLocalizations.of(context).substitutionPlan);
    }();

    // Update cafetoria
    download(() async {
      await Cafetoria.download(
          update:
              updated(newData.cafetoria, currentData.cafetoria) || gradeChanged,
          onFinished: (bool successfully) {
            if (successfully ?? true) {
              currentData.cafetoria = newData.cafetoria;
            }
          });
    }, AppLocalizations.of(context).cafetoria);

    // Update calendar
    download(() async {
      await Calendar.download(
          update:
              updated(newData.calendar, currentData.calendar) || gradeChanged,
          onFinished: (bool successfully) {
            if (successfully ?? true) {
              currentData.calendar = newData.calendar;
            }
          });
    }, AppLocalizations.of(context).calendar);

    // Update workgroups
    download(() async {
      await WorkGroups.download(
          update: updated(newData.workgroups, currentData.workgroups) ||
              gradeChanged,
          onFinished: (bool successfully) {
            if (successfully ?? true) {
              currentData.workgroups = newData.workgroups;
            }
          });
    }, AppLocalizations.of(context).workGroups);
  }

  bool updated(DateTime oldValue, DateTime newValue) =>
      !oldValue.isAtSameMomentAs(newValue);

  Future download(Function() process, String text) async {
    await process();
    countCurrentDownloads--;
    setState(() => texts.remove(text));

    if (countCurrentDownloads == 0) {
      stopwatch.stop();
      print(stopwatch.elapsedMilliseconds);
      Updates.saveUpdates();
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
