import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../Nextcloud/NextcloudPage.dart';
import '../Cafetoria/CafetoriaPage.dart';
import '../Calendar/CalendarPage.dart';
import '../Courses/CoursesPage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../SubstitutionPlan/SubstitutionPlanPage.dart';
import '../Settings/SettingsPage.dart';
import '../Timetable/TimetablePage.dart';
import '../WorkGroups/WorkGroupsPage.dart';
import 'HomePage.dart';
import 'OfflineWidget.dart';

class HomePageView extends HomePageState {
  @override
  Widget build(BuildContext context) {
    // List of pages
    List<Page> pages = [
      Page(AppLocalizations.of(context).timetable, Icons.event_note,
          TimetablePage(),
          url:
              'https://www.viktoriaschule-aachen.de/sundvplan/sps/index.html'),
      Page(AppLocalizations.of(context).substitutionPlan,
          Icons.format_list_numbered, SubstitutionPlanPage(),
          url:
              'https://www.viktoriaschule-aachen.de/sundvplan/vps/index.html'),
      Page(AppLocalizations.of(context).calendar, Icons.calendar_today,
          CalendarPage()),
      Page(AppLocalizations.of(context).cafetoria, Icons.fastfood,
          CafetoriaPage(),
          url: 'https://www.opc-asp.de/vs-aachen/'),
      Page(AppLocalizations.of(context).cloud, Icons.cloud,
          NextcloudPage(),
          url: 'https://nextcloud.aachen-vsa.logoip.de/'),
      Page(AppLocalizations.of(context).workGroups, MdiIcons.soccer,
          WorkGroupsPage()),
      Page(AppLocalizations.of(context).courses, Icons.person, CoursesPage()),
      Page(AppLocalizations.of(context).settings, Icons.settings,
          SettingsPage()),
    ];

    // Map pages to drawer items
    List<DrawerItem> drawerItems = pages
        .map((Page page) => DrawerItem(page.name, page.icon, page.url))
        .toList();

    // Create list of widget options
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
        selected: i == selectedDrawerIndex,
        onTap: () => onSelectItem(i),
      ));
    }

    // TODO: Show scan dialog

    appScaffold = Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        // Current page's title
        title: FlatButton(
          padding: EdgeInsets.only(left: 0),
          child: Text(drawerItems[selectedDrawerIndex].title,
              style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => launchURL(drawerItems[selectedDrawerIndex].url),
        ),
        elevation: 0.0,
        actions: <Widget>[
          showWeek
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: OutlineButton(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                      color: Colors.white,
                      highlightedBorderColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        currentWeek == 0 ? 'A' : 'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: weekPressed),
                )
              : Container()
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  // Logo
                  Container(
                    height: 100.0,
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
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            // Drawer options
            Column(children: drawerOptions)
          ],
        ),
      ),
      // Current page
      body: Stack(
        children: <Widget>[
          !offlineShown ? OfflineWidget() : Container(),
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
