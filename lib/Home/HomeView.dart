import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:viktoriaflutter/Nextcloud/NextcloudPage.dart';
import 'package:viktoriaflutter/Cafetoria/CafetoriaPage.dart';
import 'package:viktoriaflutter/Calendar/CalendarPage.dart';
import 'package:viktoriaflutter/Courses/CoursesPage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Settings/SettingsPage.dart';
import 'package:viktoriaflutter/Timetable/TimetablePage.dart';
import 'package:viktoriaflutter/WorkGroups/WorkGroupsPage.dart';
import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/Home/OfflineWidget.dart';

// ignore: public_member_api_docs
class HomePageView extends HomePageState {
  @override
  Widget build(BuildContext context) {
    // List of pages
    final List<Page> pages = [
      Page(AppLocalizations.of(context).timetable, Icons.event_note,
          TimetablePage(),
          url: 'https://www.viktoriaschule-aachen.de/sundvplan/sps/index.html'),
      Page(AppLocalizations.of(context).substitutionPlan,
          Icons.format_list_numbered, SubstitutionPlanPage(),
          url: 'https://www.viktoriaschule-aachen.de/sundvplan/vps/index.html'),
      Page(AppLocalizations.of(context).calendar, Icons.calendar_today,
          CalendarPage()),
      Page(AppLocalizations.of(context).cafetoria, Icons.fastfood,
          CafetoriaPage(),
          url: 'https://www.opc-asp.de/vs-aachen/'),
      Page(AppLocalizations.of(context).cloud, Icons.cloud, NextcloudPage(),
          url: 'https://nextcloud.aachen-vsa.logoip.de/'),
      Page(AppLocalizations.of(context).workGroups, MdiIcons.soccer,
          WorkGroupsPage()),
      Page(AppLocalizations.of(context).courses, Icons.person, CoursesPage()),
      Page(AppLocalizations.of(context).settings, Icons.settings,
          SettingsPage()),
    ];

    // Map pages to drawer items
    final List<DrawerItem> drawerItems = pages
        .map((Page page) => DrawerItem(page.name, page.icon, page.url))
        .toList();

    // Create list of widget options
    final drawerOptions = <Widget>[];
    for (int i = 0; i < drawerItems.length; i++) {
      final d = drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(
          d.title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        selected: i == selectedDrawerIndex,
        onTap: () => onSelectItem(i),
      ));
    }

    appScaffold = Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        // Current page's title
        title: FlatButton(
          padding: EdgeInsets.only(left: 0),
          onPressed: () => launchURL(drawerItems[selectedDrawerIndex].url),
          child: Text(drawerItems[selectedDrawerIndex].title,
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        elevation: 0,
        actions: <Widget>[
          if (showWeek)
            Container(
              margin: EdgeInsets.all(10),
              child: OutlineButton(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
                color: Colors.white,
                highlightedBorderColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () => null,
                child: Text(
                  currentWeek == 0 ? 'A' : 'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                children: <Widget>[
                  // Logo
                  Container(
                    height: 100,
                    child: SvgPicture.asset(
                      'assets/images/logo_white.svg',
                    ),
                  ),
                  // Grade
                  Text(
                    AppLocalizations.of(context).gradeName(HomePageState.grade),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            // Drawer options
            Column(children: drawerOptions)
          ],
        ),
      ),
      // Current page
      body: Stack(
        children: <Widget>[
          if(!offlineShown) OfflineWidget(),
          getDrawerItemWidget(selectedDrawerIndex, pages),
        ],
      ),
    );
    if (!offlineShown) {
      offlineShown = true;
    }
    return appScaffold;
  }
}
