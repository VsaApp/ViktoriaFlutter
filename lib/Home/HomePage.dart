import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import '../Utils/Keys.dart';
import '../Utils/Localizations.dart';
import '../Utils/Storage.dart';
import '../Utils/Tags.dart';
import '../Utils/Models.dart' as Models;
import 'HomeView.dart';
import 'NewTimetableDialog/NewTimetableDialogModel.dart';

// Define drawer item
class DrawerItem {
  String title;
  IconData icon;
  String url;

  DrawerItem(this.title, this.icon, this.url);
}

// Define page
class Page {
  String url;
  IconData icon;
  String name;
  Widget page;

  Page(this.name, this.icon, this.page, {this.url});
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageView();
}

abstract class HomePageState extends State<HomePage> {
  int currentWeek = 0;
  bool showWeek = false;
  static bool weekChangeable = true;
  Scaffold appScaffold;
  int selectedDrawerIndex = 0;
  static String grade = '';
  bool dialogShown = false;
  bool timetableChanged = false;
  String currentTimetableDate;
  bool showDialog1 = true;
  bool offlineShown = false;
  static const platform = const MethodChannel('viktoriaflutter');
  static Function(int week) weekChanged;
  static Function(int week) updateWeek;
  static Function(bool value) setShowWeek;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  static List<Function()> substitutionPlanUpdatedListeners = [];

  void _showWeek(bool value) {
    if (mounted && value != showWeek) setState(() => showWeek = value);
  }

  /// Activates od Deactivates the week toggle button
  static setWeekChangeable(bool value) {
    HomePageState.weekChangeable = value;
  }

  /// Updates the week of the week button
  void _updateWeek(int week) {
    if (mounted && week != currentWeek) setState(() => currentWeek = week);
  }

  /// Calls the listener and updates wee
  void weekPressed() {
    if (!weekChangeable) return;
    setState(() => currentWeek = currentWeek == 1 ? 0 : 1);
    if (weekChanged != null) weekChanged(currentWeek);
  }

  /// Launches an url in browser
  launchURL(String url) async {
    if (url == null) return;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Handles an incoming substitution plan notification
  Future handleSubstitutionPlanNotification(Map msg) async {
    print("received substitution plan notification");
    await SubstitutionPlanData().download(context);
    if (appScaffold != null) {
      substitutionPlanUpdatedListeners
          .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)
            .substitutionPlanUpdated
            .replaceAll(
                '%s',
                AppLocalizations.of(context)
                    .weekdays[int.parse(msg['weekday'])])),
        action: SnackBarAction(
          label: AppLocalizations.of(context).ok,
          onPressed: () {},
        ),
      ));
    }
  }

  /// Handles incoming timetable notifications
  Future handleTimetableNotification(Map msg) async {
    print("received timetable notification");
    await syncWithTags(forceSync: true);
    await TimetableData().download(context);
    Models.Data.substitutionPlan.insert();
    Models.Data.substitutionPlan.updateFilter();
    if (appScaffold != null) {
      substitutionPlanUpdatedListeners
          .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
    }
    checkIfTimetableUpdated(context);
  }

  /// Handles incoming notifications opened signals
  Future notificationOpenedHandler(String msg) async {
    print("opened: $msg");
    // Delete all notifications
    platform.invokeMethod('clearNotifications');
    // Switch to substitution plan page
    if (msg == 'substitutionPlan_channel')
      setState(() => selectedDrawerIndex = 1);
  }

  /// Handles events from the platform code (currently only android)
  Future<dynamic> _handleNotification(MethodCall call) async {
    if (call.method == 'substitution plan')
      handleSubstitutionPlanNotification(call.arguments);
    else if (call.method == 'timetable')
      handleTimetableNotification(call.arguments);
    else if (call.method == 'opened') notificationOpenedHandler(call.arguments);
  }

  @override
  void initState() {
    // Load data
    grade = Storage.get(Keys.grade) ?? '';
    showDialog1 = Storage.getBool(Keys.showShortCutDialog) ?? false;
    selectedDrawerIndex = Storage.getInt(Keys.initialPage) ?? 0;

    // Set listeners
    HomePageState.updateWeek = _updateWeek;
    HomePageState.setShowWeek = _showWeek;

    // Show the current week only for timetable and substitution plan
    if (selectedDrawerIndex <= 1) {
      setShowWeek(true);
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfTimetableUpdated(context));

    // Set the listener for android functions (Currently for incoming notifications and intents)...
    platform.setMethodCallHandler(_handleNotification);

    if (Platform.isAndroid) {
      platform.invokeMethod('channelRegistered');
    }

    substitutionPlanUpdatedListeners
        .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());

    super.initState();
  }

  static void checkIfTimetableUpdated(BuildContext context) {
    if (Storage.getBool(Keys.timetableIsNew) ?? false) {
      showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context1) {
            return NewTimetableDialog();
          });
      Storage.setBool(Keys.timetableIsNew, false);
    }
  }

  // Return the widget of the page
  getDrawerItemWidget(int pos, List<Page> pages) {
    if (pos < pages.length)
      return pages[pos].page;
    else
      return Text('Error');
  }

  // Change page
  onSelectItem(int index) {
    if (index > 1)
      setShowWeek(false);
    else
      setShowWeek(true);
    setState(() => selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }
}
