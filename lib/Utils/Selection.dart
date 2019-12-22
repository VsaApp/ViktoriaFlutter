import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Returns the selected index for the given week
int getSelectedIndex(List<TimetableSubject> subjects) {
  if (subjects.isNotEmpty) {
    // If it is the lunch break, it is always the first
    if (subjects[0].unit == 5) {
      return 0;
    }

    final String selected = Storage.getString(Keys.selection(subjects[0].block));
    if (selected != null) {
      final pSubjects = subjects.where((s) => s.courseID == selected).toList();
      if (pSubjects.length == 1) {
        //TODO: Return directly the subject and not the index
        return subjects.indexOf(pSubjects[0]);
      } else {
        //TODO: Exclude 'Freistunde'
        final pFreeLesson =
            subjects.where((s) => s.subjectID == 'Freistunde').toList();
        if (pFreeLesson.length == 1) {
          return subjects.indexOf(pFreeLesson[0]);
        }
      }
    }
  }
  return null;
}

/// Return the selected subject of the [subjects] list
TimetableSubject getSelectedSubject(List<TimetableSubject> subjects) {
  final int index = getSelectedIndex(subjects);
  return index == null ? null : subjects[index];
}

/// Set the selected subject
void setSelectedSubject(TimetableSubject selected,
    {bool defaultSelection = false}) {
  // If it is a new selection update it
  if (Storage.getString(Keys.selection(selected.block)) != selected.courseID) {
    Storage.setString(Keys.selection(selected.block), selected.courseID);
    Storage.setString(Keys.selectionTimestamp(selected.block),
        DateTime.now().toIso8601String());
  }
}
