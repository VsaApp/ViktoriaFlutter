import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../Utils/Keys.dart';
import '../Utils/Localizations.dart';
import '../Utils/SectionWidget.dart';
import '../Utils/Storage.dart';
import '../Utils/Tags.dart';
import 'SettingsPage.dart';

class SettingsPageView extends SettingsPageState {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Section(
            title: AppLocalizations.of(context).appSettings.toUpperCase(),
            children: <Widget>[
              // Show short cut dialog option
              CheckboxListTile(
                value: showShortCutDialog,
                onChanged: (bool value) {
                  setState(() {
                    Storage.setBool(Keys.showShortCutDialog, value);
                    showShortCutDialog = value;
                  });
                },
                title: Text(AppLocalizations.of(context).showShortCutDialog),
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
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: page,
                          onChanged: (p) async {
                            setState(() {
                              page = p;
                              Storage.setInt(
                                  Keys.initialPage, pages.indexOf(page));
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    child: Text(AppLocalizations.of(context).viewIntro),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/intro');
                    },
                  ),
                ),
              ),
            ],
          ),
          Section(
            title: AppLocalizations.of(context)
                .substitutionPlanSettings
                .toUpperCase(),
            children: <Widget>[
              // Sort substitution plan option
              CheckboxListTile(
                value: sortSubstitutionPlan,
                onChanged: (bool value) {
                  setState(() {
                    Storage.setBool(Keys.sortSubstitutionPlan, value);
                    sortSubstitutionPlan = value;
                  });
                },
                title: Text(AppLocalizations.of(context).sortSubstitutionPlan),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              // Get substitutionPlan notifications option
              (Platform.isIOS || Platform.isAndroid)
                  ? CheckboxListTile(
                      value: getSubstitutionPlanNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          Storage.setBool(
                              Keys.getSubstitutionPlanNotifications, value);
                          getSubstitutionPlanNotifications = value;
                          // Synchronize tags for notifications
                          initTags(context);
                        });
                      },
                      title: Text(AppLocalizations.of(context)
                          .getSubstitutionPlanNotifications),
                    )
                  : Container(),
            ],
          ),
          Section(
              title:
                  AppLocalizations.of(context).timetableSettings.toUpperCase(),
              children: <Widget>[
                // Show substitution plan in timetable option
                CheckboxListTile(
                  value: showSubstitutionPlanInTimetable,
                  onChanged: (bool value) {
                    setState(() {
                      Storage.setBool(
                          Keys.showSubstitutionPlanInTimetable, value);
                      showSubstitutionPlanInTimetable = value;
                    });
                  },
                  title: Text(AppLocalizations.of(context)
                      .showSubstitutionPlanInTimetable),
                ),
                // Show work groups in timetable option
                CheckboxListTile(
                  value: showWorkGroupsInTimetable,
                  onChanged: (bool value) {
                    setState(() {
                      Storage.setBool(Keys.showWorkGroupsInTimetable, value);
                      showWorkGroupsInTimetable = value;
                    });
                  },
                  title: Text(
                      AppLocalizations.of(context).showWorkGroupsInTimetable),
                ),
                // Show calendar in timetable option
                CheckboxListTile(
                  value: showCalendarInTimetable,
                  onChanged: (bool value) {
                    setState(() {
                      Storage.setBool(Keys.showCalendarInTimetable, value);
                      showCalendarInTimetable = value;
                    });
                  },
                  title: Text(
                      AppLocalizations.of(context).showCalendarInTimetable),
                ),
                // Show cafetoria in timetable option
                CheckboxListTile(
                  value: showCafetoriaInTimetable,
                  onChanged: (bool value) {
                    setState(() {
                      Storage.setBool(Keys.showCafetoriaInTimetable, value);
                      showCafetoriaInTimetable = value;
                    });
                  },
                  title: Text(
                      AppLocalizations.of(context).showCafetoriaInTimetable),
                ),
                // Timetable reset button
                Container(
                  margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      color: Theme.of(context).accentColor,
                      child: Text(AppLocalizations.of(context).resetTimetable),
                      onPressed: () async {
                        Storage.getKeys()
                            .where((key) =>
                                key.startsWith(Keys.selection('')) ||
                                key.startsWith(Keys.exams('')))
                            .forEach((key) {
                          Storage.remove(key);
                        });
                        syncTags();
                      },
                    ),
                  ),
                ),
              ]),
          Section(
            title: AppLocalizations.of(context).personalData.toUpperCase(),
            children: <Widget>[
              // Logout button
              Container(
                margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    child: Text(AppLocalizations.of(context).logout),
                    onPressed: () async {
                      Storage.remove(Keys.username);
                      Storage.remove(Keys.password);
                      Storage.remove(Keys.grade);
                      Storage.remove(Keys.id);
                      // Reload app
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
