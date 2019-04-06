import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../Storage.dart';
import '../Tags.dart';
import '../UnitPlan/UnitPlanData.dart' as unitplan;
import 'HomeView.dart';
import 'NewUnitplanDialog/NewUnitplanDialogModel.dart';

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
  String currentWeek = 'A';
  bool showWeek = false;
  static bool weekChangeable = true;
  Scaffold appScaffold;
  int selectedDrawerIndex = 0;
  static String grade = '';
  bool dialogShown = false;
  bool unitplanChanged = false;
  String currentUnitplanDate;
  bool showDialog1 = true;
  int logoClickCount = 0;
  bool offlineShown = false;
  static const platform = const MethodChannel('viktoriaflutter');
  static Function(String week) weekChanged;
  static Function(String week) updateWeek;
  static Function(bool value) setShowWeek;

  static List<Function()> replacementplanUpdatedListeners = [];

  void _showWeek(bool value) {
    if (mounted && value != showWeek) setState(() => showWeek = value);
  }

  static setWeekChangeable(bool value) {
    HomePageState.weekChangeable = value;
  }

  void _updateWeek(String week) {
    if (mounted && week != currentWeek) setState(() => currentWeek = week);
  }

  void weekPressed() {
    if (!weekChangeable) return;
    setState(() => currentWeek = currentWeek == 'B' ? 'A' : 'B');
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

  Future handleReplacementplanNotification(Map msg) async {
    print("received replacementplan notification");
    String grade = Storage.getString(Keys.grade);
    await unitplan.download(grade, false);
    replacementplan.load(unitplan.getUnitPlan(), false);
    if (appScaffold != null) {
      replacementplanUpdatedListeners
          .forEach((replacementplanUpdated) => replacementplanUpdated());
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)
              .replacementPlanUpdated
              .replaceAll('%s', msg['weekday']),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xAA333333),
          textColor: Colors.white);
    }
  }

  Future handleUnitplanNotification(Map msg) async {
    print("received unitplan notification");
    String grade = Storage.getString(Keys.grade);
    await unitplan.download(grade, false);
    await replacementplan.load(unitplan.getUnitPlan(), false);
    if (appScaffold != null) {
      replacementplanUpdatedListeners
          .forEach((replacementplanUpdated) => replacementplanUpdated());
    }
    checkUntiplanData();
  }

  Future notificationOpenedHandler(String msg) async {
    print("opened: $msg");
    platform.invokeMethod('clearNotifications');
    if (msg == 'replacementplan_channel')
      setState(() => selectedDrawerIndex = 1);
  }

  Future<dynamic> _handleNotification(MethodCall call) async {
    if (call.method == 'replacementplan')
      handleReplacementplanNotification(call.arguments);
    else if (call.method == 'unitplan')
      handleUnitplanNotification(call.arguments);
    else if (call.method == 'opened') notificationOpenedHandler(call.arguments);
  }

  @override
  void initState() {
    loadData();
    checkUntiplanData();
    HomePageState.updateWeek = _updateWeek;
    HomePageState.setShowWeek = _showWeek;

    if (selectedDrawerIndex <= 1) {
      setShowWeek(true);
    }

    checkUntiplanData();

    // Set the listener for android functions (Currently for incoming notifications and intents)...
    platform.setMethodCallHandler(_handleNotification);
    if (Platform.isIOS || Platform.isAndroid) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      _firebaseMessaging.getToken().then((String token) {
        assert(token != null);

        // Synchronise tags for notifications
        deleteOldTags().then((_) async {
          await initTags(token);
          await syncWithTags();
          await syncTags();
          replacementplanUpdatedListeners
              .forEach((replacementplanUpdated) => replacementplanUpdated());
        });
      });
    }

    super.initState();
  }

  void checkUntiplanData() async {
    // If it's a new version of the uniplan...
    String grade = Storage.getString(Keys.grade);
    String currentDate = await unitplan.fetchDate(grade);
    String lastDate = Storage.getString(Keys.unitplanDate);
    if (lastDate == null) {
      Storage.setString(Keys.unitplanDate, currentDate);
      currentDate = lastDate;
    }

    if (currentDate != lastDate) {
      print("There is a new unitplan, reset old data");
      currentUnitplanDate = currentDate;
      List<String> keys = Storage.getKeys().toList();
      List<String> keysToReset = keys
          .where((String key) => ((key.startsWith('room') ||
          key.startsWith('exams') ||
          (key.startsWith('unitPlan') && key
              .split('-')
              .length > 2))))
          .toList();
      keysToReset.forEach((String key) => Storage.remove(key));
      unitplanChanged = true;

      showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context1) {
            return NewUnitplanDialog();
          });
      Storage.setString(Keys.unitplanDate, currentUnitplanDate);

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

  void logoClick() {
    logoClickCount++;
    if (logoClickCount >= 7) {
      Fluttertoast.showToast(
          msg: (Storage.getBool(Keys.dev) ?? false)
              ? AppLocalizations.of(context).nowNoDeveloper
              : AppLocalizations.of(context).nowADeveloper,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xAA333333),
          textColor: Colors.white);

      logoClickCount = 0;
      Storage.setBool(Keys.dev, !(Storage.getBool(Keys.dev) ?? false));
      sendTag(Keys.dev, Storage.getBool(Keys.dev));
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
