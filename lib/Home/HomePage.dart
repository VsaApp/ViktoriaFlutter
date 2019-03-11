import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './NewUnitplanDialog/NewUnitplanDialogModel.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Messageboard/MessageboardModel.dart';
import '../Messageboard/MessageboardModel.dart' as messageboard;
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../Tags.dart';
import '../UnitPlan/UnitPlanData.dart' as unitplan;
import 'HomeView.dart';

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
  String currentWeek = 'A';
  bool showWeek = true;
  static bool weekChangeable = true;
  Scaffold appScaffold;
  int selectedDrawerIndex = 0;
  SharedPreferences sharedPreferences;
  static String grade = '';
  bool dialogShown = false;
  bool unitplanChanged = false;
  String currentUnitplanDate;
  bool showDialog1 = true;
  int logoClickCount = 0;
  bool offlineShown = false;
  static const platform = const MethodChannel('viktoriaflutter');
  static Function(String action, String type, String group) messageBoardUpdated;
  static Function(String week) weekChanged;
  static Function(String week) updateWeek;
  static Function(bool value) setShowWeek;

  static List<Function()> replacementplanUpdatedListeners = [];

  void _showWeek(bool value) {
    if (mounted) setState(() => showWeek = value);
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

  @override
  void initState() {
    loadData();
    checkUntiplanData();
    HomePageState.updateWeek = _updateWeek;
    HomePageState.setShowWeek = _showWeek;
    SharedPreferences.getInstance().then((sharedPreferences) {
      this.sharedPreferences = sharedPreferences;
      // Default follow VsaApp in messageboard...
      if (sharedPreferences.getStringList(Keys.feedGroups) == null)
        Messageboard.setFollowGroup('VsaApp');
      checkUntiplanData();
    });
    // Update replacement plan if new message received
    OneSignal.shared.setNotificationReceivedHandler((osNotification) {
      Map<String, dynamic> msg = osNotification.payload.additionalData;
      print("Received Notification: " + msg.toString());
      // If it's a silent notification, update parts of the app...
      if (msg['type'] == 'silent') {
        // If it's for the messageboard, update messageboard...
        if (msg['data']['type'].startsWith('messageboard')) {
          if (messageBoardUpdated != null)
            messageBoardUpdated(msg['data']['action'], msg['data']['type'],
                msg['data']['group']);
          else {
            if (msg['data']['type'] == 'messageboard-post')
              Messageboard.postsChanged(msg['data']['group']);
            else if (msg['data']['type'] == 'messageboard-group')
              Messageboard.groupsChanged(msg['data']['group']);
          }
        }
        // If it's for the replacementplan, update replacementplan...
        else if (msg['data']['type'].toString() ==
            'replacementplan'.toString()) {
          SharedPreferences.getInstance().then((sharedPreferences) async {
            String grade = sharedPreferences.getString(Keys.grade);
            await unitplan.download(grade, false);
            await replacementplan.load(unitplan.getUnitPlan(), false);
            if (appScaffold != null) {
              replacementplanUpdatedListeners.forEach(
                  (replacementplanUpdated) => replacementplanUpdated());
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)
                      .replacementPlanUpdated
                      .replaceAll('%s', msg['data']['weekday']),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Color(0xAA333333),
                  textColor: Colors.white);
            }
          });
        } else if (msg['data']['type'].toString() == 'unitplan'.toString()) {
          SharedPreferences.getInstance().then((sharedPreferences) async {
            String grade = sharedPreferences.getString(Keys.grade);
            await unitplan.download(grade, false);
            await replacementplan.load(unitplan.getUnitPlan(), false);
            if (appScaffold != null) {
              replacementplanUpdatedListeners.forEach(
                  (replacementplanUpdated) => replacementplanUpdated());
            }
            checkUntiplanData();
          });
        }
      }
    });
    OneSignal.shared.setNotificationOpenedHandler((osNotification) {
      platform.invokeMethod('clearNotifications');
      if (osNotification.notification.payload.additionalData['type'] ==
          'replacementplan') {
        setState(() => selectedDrawerIndex = 1);
      } else if (osNotification.notification.payload.additionalData['type'] ==
          'messageboard') {
        setState(() => selectedDrawerIndex = 2);
      }
    });
    // Initialize onesignal
    OneSignal.shared.init('1d7b8ef7-9c9d-4843-a833-8a1e9999818c');
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    // Synchronise tags for notifications
    deleteOldTags().then((_) async {
      await initTags();
      await syncTags();
      messageboard.Messageboard.syncTags();
    });
    super.initState();
  }

  void checkUntiplanData() async {
    // If it's a new version of the uniplan...#
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String grade = sharedPreferences.getString(Keys.grade);
    String currentDate = await unitplan.fetchDate(grade);
    String lastDate = sharedPreferences.getString(Keys.unitplanDate);
    if (lastDate == null) {
      sharedPreferences.setString(Keys.unitplanDate, currentDate);
      currentDate = lastDate;
    }

    if (currentDate != lastDate) {
      print("There is a new unitplan, reset old data");
      currentUnitplanDate = currentDate;
      List<String> keys = sharedPreferences.getKeys().toList();
      List<String> keysToReset = keys
          .where((String key) => ((key.startsWith('room') ||
              key.startsWith('exams') ||
              (key.startsWith('unitPlan') && key.split('-').length > 2))))
          .toList();
      keysToReset.forEach((String key) => sharedPreferences.remove(key));
      unitplanChanged = true;

      showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context1) {
            return NewUnitplanDialog();
          });
      SharedPreferences.getInstance().then(
          (SharedPreferences sharedPreferences) => sharedPreferences.setString(
              Keys.unitplanDate, currentUnitplanDate));

      syncTags();
    }
  }

  // Load saved data
  void loadData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      grade = sharedPreferences.get(Keys.grade) ?? '';
      showDialog1 = sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      selectedDrawerIndex = sharedPreferences.getInt(Keys.initialPage) ?? 0;
    });
  }

  void logoClick() {
    logoClickCount++;
    if (logoClickCount >= 7) {
      Fluttertoast.showToast(
          msg: (sharedPreferences.getBool(Keys.dev) ?? false)
              ? AppLocalizations.of(context).nowNoDeveloper
              : AppLocalizations.of(context).nowADeveloper,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xAA333333),
          textColor: Colors.white);

      logoClickCount = 0;
      sharedPreferences.setBool(
          Keys.dev, !(sharedPreferences.getBool(Keys.dev) ?? false));
      sendTag(Keys.dev, sharedPreferences.getBool(Keys.dev));
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
    setState(() => selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }
}
