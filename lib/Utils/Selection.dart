import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Returns the selected index for the given week
int getSelectedIndex(List<TimetableSubject> subjects, {int week = 0}) {
  // If it is the lunch break, it is always the first
  if (subjects.isNotEmpty && subjects[0].unit == 5) {
    return 0;
  }

  // Get all selected courses
  final List<String> courseIDs = Storage.getKeys()
      .where((key) => key.startsWith(Keys.selection('')))
      .toList();

  // Get all subjects for the correct week and with a selected course
  final List<TimetableSubject> selectedForWeek = subjects
      .where((s) =>
          (s.week == 2 || week == s.week) &&
          courseIDs.contains(Keys.selection(s.courseID)))
      .toList();
  // If there are too much selected (only possible with a bug), reset the selections to this unit
  if (selectedForWeek.length > 1) {
    selectedForWeek.forEach((s) => Storage.remove(Keys.selection(s.courseID)));
    return null;
  }
  return selectedForWeek.isNotEmpty
      ? subjects.indexOf(selectedForWeek.single)
      : null;
}

/// Return the selected subject of a [subjects] list for a given [week]
TimetableSubject getSelectedSubject(List<TimetableSubject> subjects,
    {int week = 0}) {
  final int index = getSelectedIndex(subjects, week: week);
  return index == null ? null : subjects[index];
}

/// Set the selected subject 
void setSelectedSubject(TimetableSubject selected,
    {TimetableSubject selectedB, bool defaultSelection = false}) {
  // Get all selected courses
  final List<String> courseIDs = Storage.getKeys()
      .where((key) => key.startsWith(Keys.selection('')))
      .toList();

  // If the weeks are not 1 and 0 or 0 and 1 (sum = 1), only set the first subject
  if (selectedB != null && selected.week + selectedB.week != 1) {
    selectedB = null;
  }

  // Get all units with the selected course
  Data.timetable.getAllSubjectsWithCourseID(selected.courseID).forEach((unit) {
    // Remove every unit that has the same week and is also selected
    unit.subjects.forEach((s) {
      // Check for week 0 (B)
      bool isSameWeek = s.week == selected.week || selected.week == 2;
      if (isSameWeek && courseIDs.contains(Keys.selection(s.courseID))) {
        Storage.remove(Keys.selection(s.courseID), autoSet: defaultSelection);
        courseIDs.remove(Keys.selection(s.courseID));
      }
      // Check for week 1 (A), if there is any
      if (selectedB != null) {
        isSameWeek = s.week == selectedB.week || selectedB.week == 2;
        if (isSameWeek && courseIDs.contains(Keys.selection(s.courseID))) {
          Storage.remove(Keys.selection(s.courseID), autoSet: defaultSelection);
          courseIDs.remove(Keys.selection(s.courseID));
        }
      }
    });
  });

  Storage.setBool(Keys.selection(selected.courseID), true, autoSet: defaultSelection);
  if (selectedB != null) {
    Storage.setBool(Keys.selection(selected.courseID), true, autoSet: defaultSelection);
  }
}
