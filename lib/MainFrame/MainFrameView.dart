import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Timetable/TimetablePage.dart';

/// The main frame of the app
class MainFrameView extends MainFrameState {
  @override
  Widget build(BuildContext context) {
    final bool offline = offlineShown;
    if (offline) {
      offlineShown = true;
    }
    return Scaffold(
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text('Home', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w100)),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: [
              if (selectedIndex == 0) SubstitutionPlanPage(),
              if (selectedIndex == 1) HomePage(),
              if (selectedIndex == 2) TimetablePage()
            ][0],
          )
        ],
      ),
    );
  }
}
