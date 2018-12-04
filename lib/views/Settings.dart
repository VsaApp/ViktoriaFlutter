import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Localizations.dart';
import '../Keys.dart';

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
  bool _sortReplacementPlan = true;
  bool _showReplacementPlanInUnitPlan = true;
  bool _getReplacementPlanNotifications = true;

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  void loadSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _grade = (sharedPreferences.get(Keys.grade) == null
          ? ''
          : sharedPreferences.get(Keys.grade));
      _sortReplacementPlan = sharedPreferences.getBool(Keys.sortReplacementPlan);
      _showReplacementPlanInUnitPlan = sharedPreferences.getBool(Keys.showReplacementPlanInUnitPlan);
      _getReplacementPlanNotifications = sharedPreferences.getBool(Keys.getReplacementPlanNotifications);
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
      padding: EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SettingsSection(
            title: AppLocalizations.of(context).appSettings,
            children: <Widget>[
              SwitchListTile(
                value: _sortReplacementPlan,
                onChanged: (bool value) {
                  setState(() {
                    sharedPreferences.setBool(Keys.sortReplacementPlan, value);
                    sharedPreferences.commit();
                  });
                },
                title: new Text(AppLocalizations.of(context).sortReplacementPlan),
              ),
              SwitchListTile(
                value: _showReplacementPlanInUnitPlan,
                onChanged: (bool value) {
                  setState(() {
                    sharedPreferences.setBool(Keys.showReplacementPlanInUnitPlan, value);
                    sharedPreferences.commit();
                  });
                },
                title: new Text(AppLocalizations.of(context).showReplacementPlanInUnitPlan),
              ),
              SwitchListTile(
                value: _getReplacementPlanNotifications,
                onChanged: (bool value) {
                  setState(() {
                    sharedPreferences.setBool(Keys.getReplacementPlanNotifications, value);
                    sharedPreferences.commit();
                  });
                },
                title: new Text(AppLocalizations.of(context).getReplacementPlanNotifications),
              ),
            ]
          ),
          SettingsSection(
            title: AppLocalizations.of(context).personalData,
            children: <Widget>[
              (sharedPreferences.getBool(Keys.isTeacher)
                  ? Container()
                  : SizedBox(
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
                                Navigator.of(context).pushReplacementNamed('/');
                              });
                            });
                          },
                        ),
                      ),
                    )),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
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

class SettingsSection extends StatefulWidget {
  final List<Widget> children;
  final String title;

  SettingsSection({Key key, this.children, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingsSectionView();
  }
}

class SettingsSectionView extends State<SettingsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          widget.title, 
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            ),
          ),
          child: Column(
            children: widget.children,
          )
        )
        
      ],
    );
  }
}
