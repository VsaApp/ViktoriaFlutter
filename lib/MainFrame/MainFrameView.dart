import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Timetable/TimetablePage.dart';
import 'package:viktoriaflutter/Utils/Widgets/AppBar.dart';

/// The main frame of the app
class MainFrameView extends MainFrameState {
  @override
  Widget build(BuildContext context) {
    final bool offline = offlineShown;
    if (offline) {
      offlineShown = true;
    }
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = SubstitutionPlanPage();
        break;
      case 1:
        page = HomePage();
        break;
      case 2:
        page = TimetablePage();
        break;
    }
    return Scaffold(
      appBar: GlobalAppBar.appBar,
      key: scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => setState(() => selectedIndex = index),
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.formatListBulleted), title: Container()),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.home), title: Container()),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.timetable), title: Container()),
        ],
      ),
      body: page,
    );
  }
}
