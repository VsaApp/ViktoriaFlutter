import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Localizations.dart';
import '../Keys.dart';
import 'UnitPlan.dart';
import 'ReplacementPlan.dart';

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

  @override
  void initState() {
    loadGrade();
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
      DrawerItem(AppLocalizations.of(context).unitPlan, Icons.grid_on),
      DrawerItem(AppLocalizations.of(context).replacementPlan, Icons.grid_off),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      height: 100.0,
                      fit: BoxFit.cover,
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
