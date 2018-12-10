import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viktoriaflutterplugin/viktoriaflutterplugin.dart';

import '../Keys.dart';
import '../Localizations.dart';
import 'Courses.dart';
import 'ReplacementPlan.dart';
import 'Settings.dart';
import 'UnitPlan.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
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

  @override
  void initState() {
    loadGrade();
    OneSignal.shared.init('1d7b8ef7-9c9d-4843-a833-8a1e9999818c');
    OneSignal.shared.sendTag('EF', true);
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      Viktoriaflutterplugin.showNotification(
          json.encode(notification.payload.additionalData));
    });
    Viktoriaflutterplugin.showNotification('{"type":"clear"}');
    super.initState();
  }

  void loadGrade() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      grade = (sharedPreferences.get(Keys.grade) == null
          ? ''
          : sharedPreferences.get(Keys.grade));
    });
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return UnitPlanPage();
      case 1:
        return ReplacementPlanPage();
      case 2:
        return CoursesPage();
      case 3:
        return SettingsPage();
      default:
        return Text('Error');
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerItem> drawerItems = [
      DrawerItem(AppLocalizations.of(context).unitPlan, Icons.event_note),
      DrawerItem(AppLocalizations.of(context).replacementPlan,
          Icons.format_list_numbered),
      DrawerItem(AppLocalizations.of(context).courses, Icons.person),
      DrawerItem(AppLocalizations.of(context).settings, Icons.settings),
    ];
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
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          bool selectedSubjects = sharedPreferences.getKeys().where((key) => key.contains(Keys.unitPlan)).length > 0;
    
          if (selectedSubjects){
            showDialog<String>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context1) {
                return SimpleDialog(
                  title: Center(
                    child: Text(AppLocalizations.of(context).whatDoFirst),
                  ),
                  children: drawerItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        _onSelectItem(drawerItems.indexOf(item));
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
                  }).toList(),
                );
              }
            );
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
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
