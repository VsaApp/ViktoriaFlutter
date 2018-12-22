import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../data/UnitPlan.dart';
import 'Cafetoria.dart';
import 'Calendar.dart';
import 'Courses.dart';
import 'ReplacementPlan.dart';
import 'Settings.dart';
import 'UnitPlan.dart';
import 'WorkGroups.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class Page {
  IconData icon;
  String name;
  Widget page;

  Page(this.name, this.icon, this.page);
}

class ShortCutDialog extends StatefulWidget {
  final List<DrawerItem> items;
  final Function selectItem;

  ShortCutDialog({Key key, @required this.items, @required this.selectItem})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ShortCutDialogState();
}

class ShortCutDialogState extends State<ShortCutDialog> {
  SharedPreferences sharedPreferences;
  bool _showDialog = true;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        _showDialog =
            sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return SimpleDialog(
        title: Text(AppLocalizations.of(context).whatDoFirst),
        children: <Widget>[
          Column(
              children: widget.items.map((item) {
            return GestureDetector(
              onTap: () {
                widget.selectItem(widget.items.indexOf(item));
              },
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Transform(
                    transform: new Matrix4.identity()..scale(0.8),
                    child: Container(
                      margin: EdgeInsets.all(3.0),
                      child: Icon(item.icon),
                    ),
                  ),
                ),
                label: Text(item.title),
              ),
            );
          }).toList()),
          CheckboxListTile(
            value: _showDialog,
            onChanged: (value) {
              sharedPreferences.setBool(Keys.showShortCutDialog, value);
              sharedPreferences.commit();
              setState(() {
                _showDialog = value;
              });
            },
            title: new Text(AppLocalizations.of(context).showShortCutDialog),
          ),
        ]);
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  SharedPreferences sharedPreferences;
  static String grade = '';
  bool _dialogShown = false;
  bool _showDialog = true;

  @override
  void initState() {
    loadData();
    OneSignal.shared.setNotificationReceivedHandler((osNotification) {
      DateTime now = DateTime.now();
      String lastUpdate = sharedPreferences.getString(Keys.lastUpdate);
      if (lastUpdate == null ||
          now.isAfter(DateTime.parse(lastUpdate).add(Duration(minutes: 1)))) {
        sharedPreferences.setString(Keys.lastUpdate, now.toIso8601String());
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
    OneSignal.shared.init('1d7b8ef7-9c9d-4843-a833-8a1e9999818c');
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    syncTags();
    super.initState();
  }

  void loadData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      grade = sharedPreferences.get(Keys.grade) ?? '';
      _showDialog = sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      _selectedDrawerIndex = sharedPreferences.getInt(Keys.initialPage) ?? 0;
    });
  }

  _getDrawerItemWidget(int pos, List<Page> pages) {
    if (pos < pages.length)
      return pages[pos].page;
    else
      return Text('Error');
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> pages = [
      Page(AppLocalizations
          .of(context)
          .unitPlan, Icons.event_note,
          UnitPlanPage()),
      Page(AppLocalizations
          .of(context)
          .replacementPlan,
          Icons.format_list_numbered, ReplacementPlanPage()),
      Page(AppLocalizations
          .of(context)
          .calendar, Icons.calendar_today,
          CalendarPage()),
      Page(AppLocalizations
          .of(context)
          .cafetoria, Icons.fastfood,
          CafetoriaPage()),
      Page(AppLocalizations
          .of(context)
          .workGroups, MdiIcons.soccer,
          WorkGroupsPage()),
      Page(AppLocalizations.of(context).courses, Icons.person, CoursesPage()),
      Page(AppLocalizations
          .of(context)
          .settings, Icons.settings,
          SettingsPage()),
    ];

    List<DrawerItem> drawerItems =
    pages.map((Page page) => DrawerItem(page.name, page.icon)).toList();

    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(
          d.title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    if (!_dialogShown) {
      _dialogShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        bool selectedSubjects = sharedPreferences.getKeys().where((key) {
              if (key.startsWith(
                  '${Keys.unitPlan}${sharedPreferences.getString(Keys.grade)}-')) {
                if ('-'.allMatches(key).length == 3)
                  return key.split('-')[key.split('-').length - 1] != '5';
                return true;
              }
              return false;
            }).length >
            0;
        if (selectedSubjects) {
          if (_showDialog) {
            showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context1) {
                  return ShortCutDialog(
                    items: drawerItems,
                    selectItem: _onSelectItem,
                  );
                });
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(drawerItems[_selectedDrawerIndex].title),
        elevation: 0.0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    child: SvgPicture.asset(
                      'assets/images/logo_white.svg',
                    ),
                  ),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex, pages),
    );
  }
}
