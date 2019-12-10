import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaflutter/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Models/Models.dart' as models;
import 'package:viktoriaflutter/Pages/Home/NewTimetableDialog/NewTimetableDialogModel.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFrameView.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Widgets/AppBar.dart';

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

  /// The app pages controller
  static PageController pageController;

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

  /// An main frame update listener
  static void Function(String type, dynamic value) _onUpdateListener;

  /// Checks if the app is in foreground
  static bool get isInForeground =>
      _lifecycleState == null || _lifecycleState.index == 0;

  /// Animates or jump to the given [index]
  void setSelectedIndex(int index, {bool jump}) {
    jump ??= selectedIndex != 1;
    if (!jump) {
      pageController.animateToPage(
        index,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      );
    } else {
      pageController.jumpToPage(index);
    }
  }

  /// Set the selected page
  static void setPage(int page) {
    if (_onUpdateListener != null) {
      _onUpdateListener('page', page);
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
    /// Set the static update listeners
    _onUpdateListener = _onUpdate;

    pageController = PageController(initialPage: 1);
    pageController.addListener(
        () => setState(() => selectedIndex = pageController.page.toInt()));

    // Set listener for widget bindings
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfTimetableUpdated(context));

    GlobalAppBar.addListener(_update);

    // Set the listener for android functions (Currently for incoming notifications and intents)...
    platform.setMethodCallHandler(_handleNotification);

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

  void _onUpdate(String type, dynamic value) {
    print('On update: $type $value');
    switch (type) {
      case 'page':
        selectedIndex = value;
        break;
    }
    _update();
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
