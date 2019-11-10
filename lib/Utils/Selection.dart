import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models/TimetableModel.dart';

String getKey(TimetableSubject subject) {
  return '${subject.lesson}-${subject.teacher}';
}

/// Returns the value for key and reset when the value is still in the old format...
List<String> getValue(String key) {
  var data = Storage.getStringList(key);
  if (data == null) {
    return null;
  }
  return data.cast<String>();
}

/// Logs all timetable keys and values... (Only for debugging)
void logValues() {
  String grade = Storage.getString(Keys.grade);
  List<String> keys = Storage.getKeys()
      .toList()
      .where((String key) =>
          key.startsWith('timetable') &&
          key.split('-').length > 2 &&
          key.split('-')[1] == grade)
      .toList();
  for (int i = 0; i < keys.length; i++) {
    String key = keys[i];
    print('$key: ${Storage.get(key)}');
  }
}

int getSelectedIndex(List<TimetableSubject> subjects, int day, int unit,
    {String week = 'A'}) {
  // List element 0: week A  -- element 1: week B (Only one element: week AB)
  if (unit == 5) return 0;
  List<String> selected = getValue(Keys.timetable(Storage.getString(Keys.grade),
      block: subjects[0].block, day: day, unit: unit));
  if (selected == null) return null;
  week = week.toUpperCase();
  int index = selected.length == 1 ? 0 : week == 'A' ? 0 : 1;
  if (selected.length > 1 &&
      subjects
          .where((s) => s.week != 'AB')
          .length == 0) {
    if (selected[0].endsWith('-'))
      index = 1;
    else if (selected[1].endsWith('-')) index = 0;
  }
  List<TimetableSubject> subject = subjects
      .where((TimetableSubject subject) =>
  subject.week.contains(week) && getKey(subject) == selected[index])
      .toList();
  if (subject.length == 0)
    return null;
  else
    return subjects.indexOf(subject[0]);
}

TimetableSubject getSelectedSubject(
    List<TimetableSubject> subjects, int day, int unit,
    {String week = 'A'}) {
  int index = getSelectedIndex(subjects, day, unit, week: week);
  return index == null ? null : subjects[index];
}

void setSelectedSubject(TimetableSubject selected, int day, int unit,
    {TimetableSubject selectedB}) {
  List<String> weeks = selected.week == 'AB' || selectedB == null
      ? [getKey(selected)]
      : [getKey(selected), getKey(selectedB)];
  String key = Keys.timetable(Storage.getString(Keys.grade),
      block: selected.block, day: day, unit: unit);
  Storage.setStringList(key, weeks);
}
