import 'package:shared_preferences/shared_preferences.dart';

import 'Keys.dart';
import 'UnitPlan/UnitPlanModel.dart';

String getKey(UnitPlanSubject subject) {
  return '${subject.lesson}-${subject.teacher}';
}

void logValues(SharedPreferences sharedPreferences) {
  String grade = sharedPreferences.getString(Keys.grade);
  List<String> keys = sharedPreferences
      .getKeys()
      .toList()
      .where((String key) =>
          key.startsWith('unitPlan') &&
          key.split('-').length > 2 &&
          key.split('-')[1] == grade)
      .toList();
  for (int i = 0; i < keys.length; i++) {
    String key = keys[i];
    print('$key: ${sharedPreferences.get(key)}');
  }
}

Future convertFromOldVerion(SharedPreferences sharedPreferences) async {
  String grade = sharedPreferences.getString(Keys.grade);
  List<String> keys = sharedPreferences
      .getKeys()
      .toList()
      .where((String key) =>
          key.startsWith('unitPlan') &&
          key.split('-').length > 2 &&
          key.split('-')[1] == grade)
      .toList();
  for (int i = 0; i < keys.length; i++) {
    String key = keys[i];
    List<String> fragments = key.split('-');
    List<UnitPlanSubject> subjects;
    int selected;
    int day;
    int unit;
    try {
      selected = sharedPreferences.getInt(key);
    } catch (e) {
      return;
    }
    if (fragments.length == 3) {
      String block = fragments[2];
      UnitPlan.days.forEach((UnitPlanDay day) {
        day.lessons.forEach((lesson) {
          if (lesson.subjects[0].block == block) {
            subjects = lesson.subjects;
          }
        });
      });
    } else {
      day = int.parse(fragments[2]);
      unit = int.parse(fragments[3]);
      subjects = UnitPlan.days[day].lessons[unit].subjects;
    }

    UnitPlanSubject subject = subjects[selected];
    await setSelectedSubject(sharedPreferences, subject, day, unit);
  }
}

int getSelectedIndex(SharedPreferences sharedPreferences,
    List<UnitPlanSubject> subjects, int day, int unit,
    {String week = 'A'}) {
  // List element 0: week A  -- element 1: week B (Only one element: week AB)
  List<String> selected = sharedPreferences.getStringList(Keys.unitPlan(
      sharedPreferences.getString(Keys.grade),
      block: subjects[0].block,
      day: day,
      unit: unit));
  if (selected == null) return null;
  week = week.toUpperCase();
  int index = selected.length == 1 ? 0 : week == 'A' ? 0 : 1;
  List<String> keys =
      subjects.map((UnitPlanSubject subject) => getKey(subject)).toList();
  if (!keys.contains(selected[index]))
    return null;
  else
    return keys.indexOf(selected[index]);
}

UnitPlanSubject getSelectedSubject(SharedPreferences sharedPreferences,
    List<UnitPlanSubject> subjects, int day, int unit,
    {String week = 'A'}) {
  int index =
      getSelectedIndex(sharedPreferences, subjects, day, unit, week: week);
  return index == null ? null : subjects[index];
}

Future setSelectedSubject(SharedPreferences sharedPreferences,
    UnitPlanSubject selected, int day, int unit,
    {UnitPlanSubject selectedB}) async {
  List<String> weeks = selected.week == 'AB' || true
      ? [getKey(selected)]
      : [getKey(selected), getKey(selectedB)];
  String key = Keys.unitPlan(sharedPreferences.getString(Keys.grade),
      block: selected.block, day: day, unit: unit);
  await sharedPreferences.setStringList(key, weeks);
}
