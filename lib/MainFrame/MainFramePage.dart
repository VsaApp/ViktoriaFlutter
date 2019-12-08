import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Home/NewTimetableDialog/NewTimetableDialogModel.dart';
import 'package:viktoriaflutter/MainFrame/MainFrameView.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Models.dart' as models;
import 'package:viktoriaflutter/Utils/Widgets/AppBar.dart';

/// The home page of the app
class MainFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainFrameView();
}

// ignore: public_member_api_docs
abstract class MainFrameState extends State<MainFrame>
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  static AppLifecycleState _lifecycleState;

  /// The current week
  ///
  /// Used by timetable and substitution plan
  int currentWeek = 0;

  /// Sets if [currentWeek] should be shown
  bool showWeek = false;

  /// Sets if [currentWeek] should be changeable
  static bool weekChangeable = true;

  /// [currentWeek] changed listener
  static Function(int week) weekChanged;

  /// Static function to update [currentWeek] attribute from everywhere in the app
  static Function(int week) updateWeek;

  /// Static function to set the [showWeek] attribute from everywhere in the app
  static Function(bool value) setShowWeek;

  /// Defines the highest app scaffold
  Scaffold appScaffold;

  /// Defines the selected drawer index in the side menu
  int selectedIndex = 1;

  /// Defines the grade of the user
  static String grade = '';

  /// Defines if the offline dialog was already shown
  ///
  /// Important if a user switched back from an other feature and the home page rebuilds
  bool offlineShown = false;

  /// Defines the method channel to communicate with the platform specific code
  static const platform = MethodChannel('viktoriaflutter');

  /// The static scaffold key to get this scaffold from everywhere in the app
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// A list of substitution plan updated listeners
  ///
  /// This listeners would be triggered when the app receives a silent notification from the server
  static List<Function()> substitutionPlanUpdatedListeners = [];

  /// Checks if the app is in foreground
  static bool get isInForeground =>
      _lifecycleState == null || _lifecycleState.index == 0;

  void _showWeek(bool value) {
    if (mounted && value != showWeek) {
      setState(() => showWeek = value);
    }
  }

  // ignore: use_setters_to_change_properties
  /// Activates od Deactivates the week toggle button
  static void setWeekChangeable(bool value) {
    MainFrameState.weekChangeable = value;
  }

  /// Updates the week of the week button
  void _updateWeek(int week) {
    if (mounted && week != currentWeek) {
      setState(() => currentWeek = week);
    }
  }

  /// Calls the listener and updates wee
  void weekPressed() {
    if (!weekChangeable) {
      return;
    }
    setState(() => currentWeek = currentWeek == 1 ? 0 : 1);
    if (weekChanged != null) {
      weekChanged(currentWeek);
    }
  }

  /// Launches an url in browser
  Future launchURL(String url) async {
    if (url == null) {
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Handles an incoming substitution plan notification
  Future handleSubstitutionPlanNotification(Map msg) async {
    print('received substitution plan notification');
    await SubstitutionPlanData().download(context);
    if (appScaffold != null && isInForeground) {
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
    print('received timetable notification');
    await syncWithTags(forceSync: true);
    await TimetableData().download(context);
    models.Data.substitutionPlan.insert();
    models.Data.substitutionPlan.updateFilter();
    if (appScaffold != null) {
      substitutionPlanUpdatedListeners
          .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
    }
    checkIfTimetableUpdated(context);
  }

  /// Handles incoming notifications opened signals
  Future notificationOpenedHandler(String msg) async {
    print('opened: $msg');
    // Delete all notifications
    platform.invokeMethod('clearNotifications');
    // Switch to substitution plan page
    if (msg == 'substitutionPlan_channel') {
      setState(() => selectedIndex = 1);
    }
  }

  /// Handles events from the platform code (currently only android)
  Future<dynamic> _handleNotification(MethodCall call) async {
    if (call.method == 'substitution plan') {
      handleSubstitutionPlanNotification(call.arguments);
    } else if (call.method == 'timetable') {
      handleTimetableNotification(call.arguments);
    } else if (call.method == 'opened') {
      notificationOpenedHandler(call.arguments);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
      print('State changed: ${state.index}');
    });
  }

  @override
  void initState() {
    // Set listener for widget bindings
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfTimetableUpdated(context));

    GlobalAppBar.addListener(_update);

    // Set the listener for android functions (Currently for incoming notifications and intents)...
    platform.setMethodCallHandler(_handleNotification);

    MainFrameState.updateWeek = _updateWeek;
    MainFrameState.setShowWeek = _showWeek;

    if (Platform.isAndroid) {
      platform.invokeMethod('channelRegistered');
    }

    substitutionPlanUpdatedListeners
        .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());

    super.initState();
  }

  @override
  void dispose() {
    // Remove listener for widget bindings
    GlobalAppBar.removeListener(_update);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() => null);
    }
  }

  /// Show a dialog when the timetable was updated
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
}
