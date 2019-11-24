import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../Utils/Keys.dart';
import '../Utils/Localizations.dart';
import '../Utils/SectionWidget.dart';
import '../Utils/Storage.dart';
import '../Utils/Tags.dart';
import 'SettingsPage.dart';

// ignore: public_member_api_docs
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
                padding: EdgeInsets.only(left: 15, right: 22.5),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).initialPage,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
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
                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/intro');
                    },
                    child: Text(AppLocalizations.of(context).viewIntro),
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
              if (Platform.isIOS || Platform.isAndroid)
                CheckboxListTile(
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
                ),
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
                  margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        Storage.getKeys()
                            .where((key) =>
                                key.startsWith(Keys.selection('')) ||
                                key.startsWith(Keys.exams('')))
                            .forEach(Storage.remove);
                        syncTags();
                      },
                      child: Text(AppLocalizations.of(context).resetTimetable),
                    ),
                  ),
                ),
              ]),
          Section(
            title: AppLocalizations.of(context).personalData.toUpperCase(),
            children: <Widget>[
              // Logout button
              Container(
                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      Storage.remove(Keys.username);
                      Storage.remove(Keys.password);
                      Storage.remove(Keys.grade);
                      // Reload app
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(AppLocalizations.of(context).logout),
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
