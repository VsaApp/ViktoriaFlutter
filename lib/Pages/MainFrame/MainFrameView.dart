import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaflutter/Pages/Home/HomePage.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Pages/SubstitutionPlan/SubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Pages/Timetable/TimetablePage.dart';
import 'package:viktoriaflutter/Widgets/AppBar.dart';

/// The main frame of the app
class MainFrameView extends MainFrameState {
  
  @override
  Widget build(BuildContext context) {
    final bool offline = offlineShown;
    if (offline) {
      offlineShown = true;
    }
    return Scaffold(
      appBar: GlobalAppBar.appBar,
      key: scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => setSelectedIndex(index, jump: true),
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
      body: PageView.builder(
        controller: MainFrameState.pageController,
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return SubstitutionPlanPage();
            case 1:
              return HomePage();
            case 2:
              return TimetablePage();
            default:
              return Container();
          }
        },
      ),
    );
  }
}
