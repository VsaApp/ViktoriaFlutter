import 'package:flutter/material.dart';

import './HistoryDialog/HistoryDialogWidget.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../SectionWidget.dart';
import '../Tags.dart';
import 'SettingsPage.dart';

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
          Section(
            title: AppLocalizations
                .of(context)
                .appSettings
                .toUpperCase(),
            children: <Widget>[
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
                title: Text(AppLocalizations
                    .of(context)
                    .showShortCutDialog),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 22.5),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations
                            .of(context)
                            .initialPage,
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
            ],
          ),
          Section(
            title: AppLocalizations
                .of(context)
                .replacementPlanSettings
                .toUpperCase(),
            children: <Widget>[
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
                title: Text(AppLocalizations
                    .of(context)
                    .sortReplacementPlan),
                controlAffinity: ListTileControlAffinity.trailing,
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
                title: Text(AppLocalizations
                    .of(context)
                    .getReplacementPlanNotifications),
              ),
            ],
          ),
          Section(
              title:
              AppLocalizations
                  .of(context)
                  .unitPlanSettings
                  .toUpperCase(),
              children: <Widget>[
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
                  title: Text(AppLocalizations
                      .of(context)
                      .showReplacementPlanInUnitPlan),
                ),
                // Show work groups in unit plan option
                CheckboxListTile(
                  value: showWorkGroupsInUnitPlan,
                  onChanged: (bool value) {
                    setState(() {
                      sharedPreferences.setBool(
                          Keys.showWorkGroupsInUnitPlan, value);
                      sharedPreferences.commit();
                      showWorkGroupsInUnitPlan = value;
                    });
                  },
                  title: Text(
                      AppLocalizations
                          .of(context)
                          .showWorkGroupsInUnitPlan),
                ),
                // Show calendar in unit plan option
                CheckboxListTile(
                  value: showCalendarInUnitPlan,
                  onChanged: (bool value) {
                    setState(() {
                      sharedPreferences.setBool(
                          Keys.showCalendarInUnitPlan, value);
                      sharedPreferences.commit();
                      showCalendarInUnitPlan = value;
                    });
                  },
                  title:
                  Text(AppLocalizations
                      .of(context)
                      .showCalendarInUnitPlan),
                ),
                // Show cafetoria in unit plan option
                CheckboxListTile(
                  value: showCafetoriaInUnitPlan,
                  onChanged: (bool value) {
                    setState(() {
                      sharedPreferences.setBool(
                          Keys.showCafetoriaInUnitPlan, value);
                      sharedPreferences.commit();
                      showCafetoriaInUnitPlan = value;
                    });
                  },
                  title: Text(
                      AppLocalizations
                          .of(context)
                          .showCafetoriaInUnitPlan),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      color: Theme
                          .of(context)
                          .accentColor,
                      child: Text(AppLocalizations
                          .of(context)
                          .scanUnitPlan),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context1) {
                              return AlertDialog(
                                title: Text(
                                    AppLocalizations
                                        .of(context)
                                        .scanUnitPlan),
                                content: Text(AppLocalizations
                                    .of(context)
                                    .scanUnitPlanExplanation),
                                actions: <Widget>[
                                  FlatButton(
                                    color: Theme
                                        .of(context)
                                        .accentColor,
                                    child: Text(AppLocalizations
                                        .of(context)
                                        .ok,
                                        style: TextStyle(color: Colors.black)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushNamed('/scan');
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    ),
                  ),
                ),
                // Unit plan reset button
                Container(
                  margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      color: Theme
                          .of(context)
                          .accentColor,
                      child: Text(AppLocalizations
                          .of(context)
                          .resetUnitPlan),
                      onPressed: () async {
                        sharedPreferences
                            .getKeys()
                            .where((key) =>
                        ((key.startsWith('unitPlan') ||
                            key.startsWith('room')) &&
                            key
                                .split('-')
                                .length >= 3 &&
                            !key.endsWith('-5')) ||
                            key.startsWith('exams'))
                            .forEach((key) {
                          sharedPreferences.remove(key);
                        });
                      },
                    ),
                  ),
                ),
              ]),
          Section(
            title: AppLocalizations
                .of(context)
                .personalData
                .toUpperCase(),
            children: <Widget>[
              // Grade selector
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 22.5),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      items: SettingsPageState.grades.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: grade,
                      onChanged: (grade) async {
                        setState(() {
                          sharedPreferences.setString(Keys.grade, grade);
                          sharedPreferences.commit().then((_) {
                            // Reload app
                            Navigator.of(context).pushReplacementNamed('/');
                          });
                        });
                      },
                    ),
                  ),
                ),
              ),
              // Logout button
              Container(
                margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    child: Text(AppLocalizations.of(context).logout),
                    onPressed: () async {
                      sharedPreferences.remove(Keys.username);
                      sharedPreferences.remove(Keys.password);
                      sharedPreferences.remove(Keys.grade);
                      sharedPreferences.commit().then((_) async {
                        // Reload app
                        deleteTags((await getTags()).keys.toList());
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          dev
              ? Section(
            title: AppLocalizations
                .of(context)
                .developerOptions
                .toUpperCase(),
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(AppLocalizations.of(context)
                              .replacementplanVersion),
                          onPressed: () => showDialog<String>(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context1) =>
                                  HistoryDialog(type: 'replacementplan')),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                            color: Theme.of(context).accentColor,
                            child: Text(
                                AppLocalizations.of(context).unitplanVersion),
                            onPressed: () => showDialog<String>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context1) =>
                                    HistoryDialog(type: 'unitplan'))),
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
