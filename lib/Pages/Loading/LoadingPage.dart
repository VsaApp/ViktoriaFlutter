import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:viktoriaflutter/Downloader/CafetoriaData.dart';
import 'package:viktoriaflutter/Downloader/CalendarData.dart';
import 'package:viktoriaflutter/Downloader/RoomsData.dart';
import 'package:viktoriaflutter/Downloader/SubjectsData.dart';
import 'package:viktoriaflutter/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Downloader/TeachersData.dart';
import 'package:viktoriaflutter/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Downloader/UpdatesData.dart';
import 'package:viktoriaflutter/Downloader/WorkGroupsData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Pages/Loading/LoadingView.dart';
import 'package:viktoriaflutter/Utils/Errors.dart' as bugs;
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

/// Downloads all data and visualize the process
class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageView();
}

// ignore: public_member_api_docs
abstract class LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  /// The number of download that must be downloaded
  final int allDownloadsCount = 9;

  /// The number of downloads that still have to download
  int countCurrentDownloads = 9;

  /// The dimension of the ginko image
  double centerWidgetDimensions = 150;

  /// All download info texts
  List<String> texts = [];

  /// Defines if the [texts] should be shown
  bool showTexts = false;

  /// Defines the current animation direction
  bool animationForward = true;

  /// Defines the timer to hide the [texts] for a short time
  Timer textTimer;

  /// The animation for the ginko animation
  Animation animation;

  /// The controller for the ginko animation
  AnimationController controller;

  /// The stopwatch for the download process
  Stopwatch _stopwatch;

  /// Defines if the user is logged in
  bool loggedIn = true;

  @override
  void initState() {
    () async {
      await Storage.init();
      bugs.init();

      // Set default options
      if (Storage.get(Keys.showSubstitutionPlanInTimetable) == null ||
          Storage.get(Keys.getSubstitutionPlanNotifications) == null ||
          Storage.get(Keys.showWorkGroupsInTimetable) == null ||
          Storage.get(Keys.showCalendarInTimetable) == null ||
          Storage.get(Keys.showCafetoriaInTimetable) == null) {
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
        texts = [
          AppLocalizations.of(context).updates,
          AppLocalizations.of(context).timetable,
          AppLocalizations.of(context).substitutionPlan,
          AppLocalizations.of(context).workGroups,
          AppLocalizations.of(context).calendar,
          AppLocalizations.of(context).subjects,
          AppLocalizations.of(context).rooms,
          AppLocalizations.of(context).teachers,
          AppLocalizations.of(context).cafetoria,
        ]..shuffle();
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
        animation = Tween<double>(begin: -0, end: 0.01).animate(controller)
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
    if (textTimer != null) {
      textTimer.cancel();
    }
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Inform the user about a too old app version
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

  /// Initialize firebase cloud messaging
  Future initFirebase() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print('Settings registered: $settings');
      });
      final String token = await _firebaseMessaging.getToken();
      if (token != null) {
        // Synchronize tags for notifications
        await initTags(context);
        await syncTags();
      } else {
        print('Error: Firebase token is null');
      }
    }
  }

  /// Downloads all data from server
  Future downloadAll() async {
    _stopwatch = Stopwatch()..start();

    // Get current versions of local data
    final updates = UpdatesData();
    final currentData = updates.getUpdates(loaded: false);

    // Get the versions of server data
    final int status = await updates.download(context);
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
    final String oldGrade = Storage.getString(Keys.grade) ?? '--';
    final String newGrade = newData.grade;
    final bool gradeChanged = newGrade != oldGrade;
    Storage.setString(Keys.grade, newGrade);

    // Download updates finished
    setState(() {
      countCurrentDownloads--;
      texts.remove(AppLocalizations.of(context).updates);
    });

    // Get the current app version to check the min app level
    final String appVersion = (await rootBundle.loadString('pubspec.yaml'))
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
    final Map<String, dynamic> newDataMap = newData.toMap();
    final Map<String, dynamic> currentDataMap = currentData.toMap();

    // ignore: prefer_interpolation_to_compose_strings
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
        final int status = await SubjectsData().download(
          context,
          update: updated(newData.subjects, currentData.subjects),
        );
        if (status == StatusCodes.success) {
          currentData.teachers = newData.teachers;
        }
      }, AppLocalizations.of(context).subjects);

      // Update rooms
      await download(() async {
        final int status = await RoomsData().download(
          context,
          update: updated(newData.rooms, currentData.rooms),
        );
        if (status == StatusCodes.success) {
          currentData.rooms = newData.rooms;
        }
      }, AppLocalizations.of(context).rooms);

      // Update teachers
      await download(() async {
        final int status = await TeachersData().download(
          context,
          update: updated(newData.teachers, currentData.teachers),
        );
        if (status == StatusCodes.success) {
          currentData.teachers = newData.teachers;
        }
      }, AppLocalizations.of(context).teachers);

      // Update timetable
      await download(() async {
        final int status = await TimetableData().download(context,
            update: updated(newData.timetable, currentData.timetable) ||
                gradeChanged);
        if (status == StatusCodes.success) {
          currentData.timetable = newData.timetable;
        }
        await initFirebase();
      }, AppLocalizations.of(context).timetable);

      // Update substitution plan
      await download(() async {
        final int status = await SubstitutionPlanData().download(
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
      final int status = await CafetoriaData().download(
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
      final int status = await CalendarData().download(
        context,
        update: updated(newData.calendar, currentData.calendar) || gradeChanged,
      );
      if (status == StatusCodes.success) {
        currentData.calendar = newData.calendar;
      }
    }, AppLocalizations.of(context).calendar);

    // Update workgroups
    download(() async {
      final int status = await WorkGroupsData().download(
        context,
        update:
            updated(newData.workgroups, currentData.workgroups) || gradeChanged,
      );
      if (status == StatusCodes.success) {
        currentData.workgroups = newData.workgroups;
      }
    }, AppLocalizations.of(context).workGroups);
  }

  /// Compares the dates
  bool updated(DateTime oldValue, DateTime newValue) =>
      !oldValue.isAtSameMomentAs(newValue);

  /// Executes one download process and removes the download text
  ///
  /// If it was the last process, it starts the app
  Future<void> download(Future<void> Function() process, String text) async {
    await process();
    countCurrentDownloads--;
    setState(() => texts.remove(text));

    if (countCurrentDownloads <= 0) {
      _stopwatch.stop();
      print(_stopwatch.elapsedMilliseconds);
      UpdatesData().saveUpdates();
      print('everything loaded');
      // After download show app
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        print('open home');
        Navigator.of(context).pushReplacementNamed('/main');
      });
    }
  }
}
