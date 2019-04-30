import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/Keys.dart';
import '../Utils/Localizations.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../Utils/Storage.dart';
import '../Utils/Tags.dart';
import '../Utils/MuteService.dart' as MuteService;
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
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(AppLocalizations
            .of(context)
            .replacementPlanUpdated
            .replaceAll('%s', msg['weekday'])),
        action: SnackBarAction(
          label: AppLocalizations
              .of(context)
              .ok,
          onPressed: () {},
        ),
      ));
    }
  }

  Future handleUnitplanNotification(Map msg) async {
    print("received unitplan notification");
    String grade = Storage.getString(Keys.grade);
    await unitplan.download(grade, false);
    replacementplan.load(unitplan.getUnitPlan(), false);
    if (appScaffold != null) {
      replacementplanUpdatedListeners
          .forEach((replacementplanUpdated) => replacementplanUpdated());
    }
    checkIfUnitplanUpdated(context);
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
    HomePageState.updateWeek = _updateWeek;
    HomePageState.setShowWeek = _showWeek;

    MuteService.init();

    if (selectedDrawerIndex <= 1) {
      setShowWeek(true);
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfUnitplanUpdated(context));

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

        // Synchronise tags for notifications
        await initTags(token);
        await syncWithTags();
        await syncTags();
        replacementplanUpdatedListeners
            .forEach((replacementplanUpdated) => replacementplanUpdated());
      });
    }

    if (Platform.isAndroid) {
      platform.invokeMethod('channelRegistered');
    }

    super.initState();
  }

  static void checkIfUnitplanUpdated(BuildContext context) {
    if (Storage.getBool(Keys.unitPlanIsNew) ?? false) {
      showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context1) {
            return NewUnitplanDialog();
          });
      Storage.setBool(Keys.unitPlanIsNew, false);
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
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text((Storage.getBool(Keys.dev) ?? false)
            ? AppLocalizations
            .of(context)
            .nowNoDeveloper
            : AppLocalizations
            .of(context)
            .nowADeveloper),
        action: SnackBarAction(
          label: AppLocalizations
              .of(context)
              .ok,
          onPressed: () {},
        ),
      ));

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
