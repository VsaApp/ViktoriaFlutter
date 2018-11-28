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

  @override
  void initState() {
    loadGrade();
    super.initState();
  }

  void loadGrade() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _grade = (sharedPreferences.get(Keys.grade) == null
          ? ''
          : sharedPreferences.get(Keys.grade));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SettingsSection(
            children: <Widget>[
              SizedBox(
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
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(AppLocalizations.of(context).logout),
                    onPressed: () async {
                      sharedPreferences.clear();
                      sharedPreferences.commit().then((_) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    },
                  ),
                ),
              ),
            ],
            title: AppLocalizations.of(context).personalData,
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
        Container(
          child: ListTile(
            title: Text(widget.title),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black54,
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        ),
        Column(
          children: widget.children,
        )
      ],
    );
  }
}
