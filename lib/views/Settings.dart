import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import 'ReplacementPlan.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageView();
  }
}

class SettingsPageView extends State<SettingsPage> {
  SharedPreferences sharedPreferences;
  static List<String> _grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];
  String _grade = _grades[0];
  List<String> _pages = [];
  String _page = '';
  bool _sortReplacementPlan = true;
  bool _showReplacementPlanInUnitPlan = true;
  bool _getReplacementPlanNotifications = true;
  bool _showShortCutDialog = true;

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  void loadSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _grade = sharedPreferences.get(Keys.grade) ?? '';
      _sortReplacementPlan =
          sharedPreferences.getBool(Keys.sortReplacementPlan) ?? true;
      _showReplacementPlanInUnitPlan =
          sharedPreferences.getBool(Keys.showReplacementPlanInUnitPlan) ?? true;
      _getReplacementPlanNotifications =
          sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
              true;
      _showShortCutDialog =
          sharedPreferences.getBool(Keys.showShortCutDialog) ?? true;
      _pages = [
        AppLocalizations.of(context).unitPlan,
        AppLocalizations.of(context).replacementPlan,
        AppLocalizations.of(context).courses
      ];
      _page = _pages[sharedPreferences.getInt(Keys.initialPage) ?? 0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Section(title: AppLocalizations.of(context).appSettings, children: <
              Widget>[
            CheckboxListTile(
              value: _sortReplacementPlan,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(Keys.sortReplacementPlan, value);
                  sharedPreferences.commit();
                  _sortReplacementPlan = value;
                });
              },
              title: new Text(AppLocalizations.of(context).sortReplacementPlan),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            CheckboxListTile(
              value: _showReplacementPlanInUnitPlan,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(
                      Keys.showReplacementPlanInUnitPlan, value);
                  sharedPreferences.commit();
                  _showReplacementPlanInUnitPlan = value;
                });
              },
              title: new Text(
                  AppLocalizations.of(context).showReplacementPlanInUnitPlan),
            ),
            CheckboxListTile(
              value: _getReplacementPlanNotifications,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(
                      Keys.getReplacementPlanNotifications, value);
                  sharedPreferences.commit();
                  _getReplacementPlanNotifications = value;
                });
              },
              title: new Text(
                  AppLocalizations.of(context).getReplacementPlanNotifications),
            ),
            CheckboxListTile(
              value: _showShortCutDialog,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(Keys.showShortCutDialog, value);
                  sharedPreferences.commit();
                  _showShortCutDialog = value;
                });
              },
              title: new Text(AppLocalizations.of(context).showShortCutDialog),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 22.5),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      AppLocalizations.of(context).initialPage,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        items: _pages.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        value: _page,
                        onChanged: (page) async {
                          setState(() {
                            _page = page;
                            sharedPreferences.setInt(
                                Keys.initialPage, _pages.indexOf(page));
                            sharedPreferences.commit();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          Section(
            title: AppLocalizations.of(context).personalData,
            children: <Widget>[
              (sharedPreferences.getBool(Keys.isTeacher)
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 22.5),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            items: _grades.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            value: _grade,
                            onChanged: (grade) async {
                              setState(() {
                                sharedPreferences.setString(Keys.grade, grade);
                                sharedPreferences.commit().then((_) {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    )),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    child: Text(AppLocalizations.of(context).logout),
                    onPressed: () async {
                      sharedPreferences.remove(Keys.username);
                      sharedPreferences.remove(Keys.password);
                      sharedPreferences.remove(Keys.grade);
                      sharedPreferences.remove(Keys.isTeacher);
                      sharedPreferences.commit().then((_) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
