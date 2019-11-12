import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Returns the selected index for the given week
int getSelectedIndex(List<TimetableSubject> subjects, {int week = 0}) {
  // If it is the lunch break, it is always the first
  if (subjects.length > 0 && subjects[0].unit == 5) return 0;

  // Get all selected courses
  List<String> courseIDs = Storage.getKeys()
      .where((key) => key.startsWith(Keys.selection('')))
      .toList();

  // Get all subjects for the correct week and with a selected course
  List<TimetableSubject> selectedForWeek = subjects
      .where((s) =>
          (s.week == 2 || week == s.week) && courseIDs.contains(s.courseID))
      .toList();
  return selectedForWeek.length > 0
      ? subjects.indexOf(selectedForWeek.single)
      : null;
}

TimetableSubject getSelectedSubject(List<TimetableSubject> subjects,
    {int week = 0}) {
  int index = getSelectedIndex(subjects, week: week);
  return index == null ? null : subjects[index];
}

void setSelectedSubject(TimetableSubject selected,
    {TimetableSubject selectedB}) {
  // Get all selected courses
  List<String> courseIDs = Storage.getKeys()
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
      if (isSameWeek && courseIDs.contains(s.courseID)) {
        Storage.remove(s.courseID);
        courseIDs.remove(s.courseID);
      }
      // Check for week 1 (A), if there is any
      if (selectedB != null) {
        isSameWeek = s.week == selectedB.week || selectedB.week == 2;
        if (isSameWeek && courseIDs.contains(s.courseID)) {
          Storage.remove(s.courseID);
          courseIDs.remove(s.courseID);
        }
      }
    });
  });
}
