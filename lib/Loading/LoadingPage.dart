import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Errors.dart' as bugs;
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Utils/Downloader/UpdatesData.dart';
import 'package:viktoriaflutter/Utils/Downloader/TeachersData.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubjectsData.dart';
import 'package:viktoriaflutter/Utils/Downloader/RoomsData.dart';
import 'package:viktoriaflutter/Utils/Downloader/CalendarData.dart';
import 'package:viktoriaflutter/Utils/Downloader/CafetoriaData.dart';
import 'package:viktoriaflutter/Utils/Downloader/WorkGroupsData.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'LoadingView.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

abstract class LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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

      WidgetsBinding.instance.addPostFrameCallback((a) async {
        // Apply the android app theme
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

        // Add all download texts
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

      // Show download texts only after 3 seconds
      textTimer = Timer(Duration(seconds: 3), () {
        setState(() {
          showTexts = true;
        });
      });

      // Start animation controller (For the loading app icon)
      controller = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );

      // Animate from one site to the other and so on
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

  Future initFirebase() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      String token = await _firebaseMessaging.getToken();
      assert(token != null);

      // Synchronize tags for notifications
      await initTags(context);
      await syncTags();
    }
  }

  Future downloadAll() async {
    stopwatch = Stopwatch()..start();

    // Get current versions of local data
    final updates = UpdatesData();
    final currentData = updates.getUpdates(loaded: false);

    // Get the versions of server data
    int status = await updates.download(context);
    if (status == StatusCodes.unauthorized) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    Updates newData = Data.updates;
    if (status == StatusCodes.failed ||
        status == StatusCodes.offline ||
        newData == null) {
      print('Offline');
      await updates.download(context, update: false);
      newData = Data.updates;
    }

    // Compares the old and new grade
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

    // If the app is too old, show non dismissible dialog
    if (newData.minAppLevel > int.parse(appVersion.split('+')[1])) {
      showOldAppDialog(appVersion);
      return;
    }

    // Print data count to download
    Map<String, dynamic> newDataMap = newData.toMap();
    Map<String, dynamic> currentDataMap = currentData.toMap();
    print('Downloading ' +
        (newDataMap.keys
                .map((key) =>
                    newDataMap[key] != currentDataMap[key] || gradeChanged)
                .where((a) => a)
                .length)
            .toString() +
        '/$allDownloadsCount files');

    // Download subjects, rooms, teachers, timetable and substitution plan in the correct order
    () async {
      // Update subjects
      await download(() async {
        int status = await SubjectsData().download(
          context,
          update: updated(newData.subjects, currentData.subjects),
        );
        if (status == StatusCodes.success) {
          currentData.teachers = newData.teachers;
        }
      }, AppLocalizations.of(context).subjects);

      // Update rooms
      await download(() async {
        await RoomsData().download(
          context,
          update: updated(newData.rooms, currentData.rooms),
        );
        if (status == StatusCodes.success) {
          currentData.rooms = newData.rooms;
        }
      }, AppLocalizations.of(context).rooms);

      // Update teachers
      await download(() async {
        int status = await TeachersData().download(
          context,
          update: updated(newData.teachers, currentData.teachers),
        );
        if (status == StatusCodes.success) {
          currentData.teachers = newData.teachers;
        }
      }, AppLocalizations.of(context).teachers);

      // Update timetable
      await download(() async {
        int status = await TimetableData().download(context,
            update: updated(newData.timetable, currentData.timetable) ||
                gradeChanged);
        if (status == StatusCodes.success) {
          currentData.timetable = newData.timetable;
        }
        await initFirebase();
      }, AppLocalizations.of(context).timetable);

      // Update substitution plan
      await download(() async {
        int status = await SubstitutionPlanData().download(
          context,
          update:
              updated(newData.substitutionPlan, currentData.substitutionPlan),
        );
        if (status == StatusCodes.success) {
          currentData.substitutionPlan = newData.substitutionPlan;
        }
      }, AppLocalizations.of(context).substitutionPlan);
    }();

    // Update cafetoria
    download(() async {
      int status = await CafetoriaData().download(
        context,
        update:
            updated(newData.cafetoria, currentData.cafetoria) || gradeChanged,
      );
      if (status == StatusCodes.success) {
          currentData.cafetoria = newData.cafetoria;
        }
    }, AppLocalizations.of(context).cafetoria);

    // Update calendar
    download(() async {
      int status = await CalendarData().download(
        context,
        update: updated(newData.calendar, currentData.calendar) || gradeChanged,
      );
      if (status == StatusCodes.success) {
          currentData.calendar = newData.calendar;
        }
    }, AppLocalizations.of(context).calendar);

    // Update workgroups
    download(() async {
      int status = await WorkGroupsData().download(
        context,
        update:
            updated(newData.workgroups, currentData.workgroups) || gradeChanged,
      );
      if (status == StatusCodes.success) {
          currentData.workgroups = newData.workgroups;
        }
    }, AppLocalizations.of(context).workGroups);
  }

  bool updated(DateTime oldValue, DateTime newValue) =>
      !oldValue.isAtSameMomentAs(newValue);

  Future<void> download(Future<void> Function() process, String text) async {
    await process();
    countCurrentDownloads--;
    setState(() => texts.remove(text));

    if (countCurrentDownloads <= 0) {
      stopwatch.stop();
      print(stopwatch.elapsedMilliseconds);
      UpdatesData().saveUpdates();
      print('everything loaded');
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int storedVersion = Storage.getInt(Keys.slidesVersion) ?? 0;
        int currentVersion = 3;
        if (currentVersion != storedVersion) {
          Storage.setInt(Keys.slidesVersion, currentVersion);
          print('open intro');
          Navigator.of(context).pushReplacementNamed('/intro');
        } else {
          print('open home');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }
}
