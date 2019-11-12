import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../SubstitutionPlan/SubstitutionPlanData.dart' as substitutionPlan;
import '../Timetable/TimetableData.dart' as timetable;
import '../Utils/Keys.dart';
import '../Utils/Localizations.dart';
import '../Utils/Storage.dart';
import '../Utils/Tags.dart';
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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

  static setWeekChangeable(bool value) {
    HomePageState.weekChangeable = value;
  }

  void _updateWeek(int week) {
    if (mounted && week != currentWeek) setState(() => currentWeek = week);
  }

  void weekPressed() {
    if (!weekChangeable) return;
    setState(() => currentWeek = currentWeek == 1 ? 0 : 1);
    if (weekChanged != null) weekChanged(currentWeek);
  }

  launchURL(String url) async {
    if (url == null) return;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future handleSubstitutionPlanNotification(Map msg) async {
    print("received substitution plan notification");
    Storage.remove(Keys.historyDate('substitutionPlan'));
    await substitutionPlan.download();
    if (appScaffold != null) {
      substitutionPlanUpdatedListeners
          .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)
            .substitutionPlanUpdated
            .replaceAll('%s', msg['weekday'])),
        action: SnackBarAction(
          label: AppLocalizations.of(context).ok,
          onPressed: () {},
        ),
      ));
    }
    checkIfTimetableUpdated(context);
  }

  Future handleTimetableNotification(Map msg) async {
    print("received timetable notification");
    await syncWithTags();
    await timetable.download(false);
    await substitutionPlan.download();
    if (appScaffold != null) {
      substitutionPlanUpdatedListeners
          .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
    }
    checkIfTimetableUpdated(context);
  }

  Future notificationOpenedHandler(String msg) async {
    print("opened: $msg");
    platform.invokeMethod('clearNotifications');
    if (msg == 'substitutionPlan_channel')
      setState(() => selectedDrawerIndex = 1);
  }

  Future<dynamic> _handleNotification(MethodCall call) async {
    if (call.method == 'substitutionPlan')
      handleSubstitutionPlanNotification(call.arguments);
    else if (call.method == 'timetable')
      handleTimetableNotification(call.arguments);
    else if (call.method == 'opened') notificationOpenedHandler(call.arguments);
  }

  @override
  void initState() {
    loadData();
    HomePageState.updateWeek = _updateWeek;
    HomePageState.setShowWeek = _showWeek;

    if (selectedDrawerIndex <= 1) {
      setShowWeek(true);
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfTimetableUpdated(context));

    // Set the listener for android functions (Currently for incoming notifications and intents)...
    platform.setMethodCallHandler(_handleNotification);
    if (Platform.isIOS || Platform.isAndroid) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      _firebaseMessaging.getToken().then((String token) async {
        assert(token != null);

        // Synchronize tags for notifications
        await initTags(context, token);
        await syncWithTags();
        await syncTags();
        substitutionPlanUpdatedListeners
            .forEach((substitutionPlanUpdated) => substitutionPlanUpdated());
      });
    }

    if (Platform.isAndroid) {
      platform.invokeMethod('channelRegistered');
    }

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
      syncTags();
    }
  }

  // Load saved data
  void loadData() async {
    setState(() {
      grade = Storage.get(Keys.grade) ?? '';
      showDialog1 = Storage.getBool(Keys.showShortCutDialog) ?? true;
      selectedDrawerIndex = Storage.getInt(Keys.initialPage) ?? 0;
    });
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
