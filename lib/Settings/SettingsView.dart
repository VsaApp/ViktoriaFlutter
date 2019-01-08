import 'package:flutter/material.dart';
import 'SettingsPage.dart';
import '../SectionWidget.dart';
import '../Localizations.dart';
import '../Keys.dart';
import '../UnitPlan/UnitPlanData.dart';

class SettingsPageView extends SettingsPageState {
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
            // Sort replacement plan option
            CheckboxListTile(
              value: sortReplacementPlan,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(Keys.sortReplacementPlan, value);
                  sharedPreferences.commit();
                  sortReplacementPlan = value;
                });
              },
              title: new Text(AppLocalizations.of(context).sortReplacementPlan),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            // Show replacement plan in unit plan option
            CheckboxListTile(
              value: showReplacementPlanInUnitPlan,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(
                      Keys.showReplacementPlanInUnitPlan, value);
                  sharedPreferences.commit();
                  showReplacementPlanInUnitPlan = value;
                });
              },
              title: new Text(
                  AppLocalizations.of(context).showReplacementPlanInUnitPlan),
            ),
            // Get replacementplan notifications option
            CheckboxListTile(
              value: getReplacementPlanNotifications,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(
                      Keys.getReplacementPlanNotifications, value);
                  sharedPreferences.commit();
                  getReplacementPlanNotifications = value;
                  // Synchronise tags for notifications
                  syncTags();
                });
              },
              title: new Text(
                  AppLocalizations.of(context).getReplacementPlanNotifications),
            ),
            // Show short cut dialog option
            CheckboxListTile(
              value: showShortCutDialog,
              onChanged: (bool value) {
                setState(() {
                  sharedPreferences.setBool(Keys.showShortCutDialog, value);
                  sharedPreferences.commit();
                  showShortCutDialog = value;
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
                  // Initial page selector
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        items: pages.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        value: page,
                        onChanged: (page) async {
                          setState(() {
                            page = page;
                            sharedPreferences.setInt(
                                Keys.initialPage, pages.indexOf(page));
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
                  :
                  // Grade selector
                  Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 22.5),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            items: SettingsPageState.grades.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            value: grade,
                            onChanged: (grade) async {
                              setState(() {
                                sharedPreferences.setString(Keys.grade, grade);
                                sharedPreferences.commit().then((_) {
                                  // Reload app
                                  syncTags();
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    )),
              // Logout button
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
                        // Reload app
                        syncTags();
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
