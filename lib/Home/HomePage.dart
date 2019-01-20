import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Messageboard/MessageboardModel.dart';
import '../UnitPlan/UnitPlanModel.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../Messageboard/MessageboardModel.dart' as messageboard;
import 'HomeView.dart';
import '../Tags.dart';

// Define drawer item
class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

// Define page
class Page {
  IconData icon;
  String name;
  Widget page;

  Page(this.name, this.icon, this.page);
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageView();
}

abstract class HomePageState extends State<HomePage> {
  Scaffold appScaffold;
  int selectedDrawerIndex = 0;
  SharedPreferences sharedPreferences;
  static String grade = '';
  bool dialogShown = false;
  bool showDialog1 = true;
  int logoClickCount = 0;
  static const platform = const MethodChannel('viktoriaflutter');
  static Function(String action, String type, String group) messageBoardUpdated;
  static List<Function()> replacementplanUpdatedListeners = [];

  @override
  void initState() {
    loadData();
    // Update replacement plan if new message received
    OneSignal.shared.setNotificationReceivedHandler((osNotification) {
      Map<String, dynamic> msg = osNotification.payload.additionalData;
      print("Received Notification: " + msg.toString());
      // If it's a silent notification, update parts of the app...
      if (msg['type'] == 'silent'){
        // If it's for the messageboard, update messageboard...
        if (msg['data']['type'].startsWith('messageboard')) {
          if (messageBoardUpdated != null) messageBoardUpdated(msg['data']['action'], msg['data']['type'], msg['data']['group']);
          else {
            if (msg['data']['type'] == 'messageboard-post') Messageboard.postsChanged(msg['data']['group']);
            else if (msg['data']['type'] == 'messageboard-group') Messageboard.groupsChanged(msg['data']['group']);
          }
        }
        // If it's for the messageboard, update messageboard...
        else if (msg['data']['type'].toString() == 'replacementplan'.toString()) {
          print('update');
          SharedPreferences.getInstance().then((sharedPreferences) async {
            String grade = sharedPreferences.getString(Keys.grade);
            await replacementplan.downloadDay(grade, msg['data']['day']);
            UnitPlan.resetChanges();
            await replacementplan.load(grade);
            print("downloaded $mounted");
            if (appScaffold != null) {
              replacementplanUpdatedListeners.forEach((replacementplanUpdated) => replacementplanUpdated());
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context).replacementPlanUpdated.replaceAll('%s', msg['data']['weekday']) ,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Color(0xAA333333),
                textColor: Colors.white
              );
            }
          });
        }
      }
    });
    OneSignal.shared.setNotificationOpenedHandler((osNotification) {
      platform.invokeMethod('clearNotifications');
      if (osNotification.notification.payload.additionalData['type'] == 'replacementplan') {
        setState(() => selectedDrawerIndex = 1);
      } else if (osNotification.notification.payload.additionalData['type'] == 'messageboard') {
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
        msg: (sharedPreferences.getBool(Keys.dev) ?? false) ? AppLocalizations.of(context).nowNoDeveloper : AppLocalizations.of(context).nowADeveloper,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color(0xAA333333),
        textColor: Colors.white
      );
      
      logoClickCount = 0;
      sharedPreferences.setBool(Keys.dev, !(sharedPreferences.getBool(Keys.dev) ?? false));
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
