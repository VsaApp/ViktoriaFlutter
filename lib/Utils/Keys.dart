/// Defines all preferences keys...
class Keys {
  /// Saves the selected grade...
  static String get grade {
    return 'grade';
  }

  /// Saves the user group (pupil/developer/teacher)
  static String get group {
    return 'group';
  }

  /// Saves the current timetable date
  static String get timetableDate {
    return 'timetableDate';
  }

  /// Saves the length of the timetable days
  static String get daysLengths {
    return 'daysLengths';
  }

  /// Saves if the user is a developer
  static String get dev {
    return 'dev';
  }

  /// Saves all offline bugs
  static String get bugs {
    return 'bugs';
  }

  /// Saves the two last selected grades...
  static String get lastGrades {
    return 'lastGrades';
  }

  /// Saves the last notification received time...
  static String get lastUpdate {
    return 'lastUpdate';
  }

  /// Saves the cafetoria data...
  static String get cafetoria {
    return 'cafetoria';
  }

  /// Saves the cafetoria data...
  static String get cafetoriaModified {
    return 'cafetoriaModified';
  }

  /// Saves the keyfob id...
  static String get cafetoriaId {
    return 'cafetoriaUsername';
  }

  /// Saves the keyfob password...
  static String get cafetoriaPassword {
    return 'cafetoriaPassword';
  }

  /// Saves the app username...
  static String get username {
    return 'username';
  }

  /// Saves the app password...
  static String get password {
    return 'password';
  }

  /// Saves if the substitution plan should be sorted...
  static String get sortSubstitutionPlan {
    return 'sortSubstitutionPlan';
  }

  /// Saves if the substitution plan should shown in the timetable...
  static String get showSubstitutionPlanInTimetable {
    return 'showSubstitutionPlanInTimetable';
  }

  /// Saves if the user get substitution plan notifications...
  static String get getSubstitutionPlanNotifications {
    return 'getSubstitutionPlanNotifications';
  }

  /// timetable-GRADE saves the timetable json string...
  static String timetable(String grade) {
    return 'timetable-$grade';
  }

  /// selection-block saves the selected course for a block
  static String selection(String block) {
    return 'selection-$block';
  }

  /// timestamp-selection-block saves the last changed timestamp of a course selection
  static String selectionTimestamp(String block) {
    return 'timestamp-selection-$block';
  }

  /// substitutionPlan saves the substitution plan...
  static String get substitutionPlan {
    return 'substitutionPlan';
  }

  /// exams-subject saves if user writing exams in this course...
  static String exams(String subject) {
    return 'exams-$subject';
  }

  /// timestamp-exams-subject saves the last changed timestamp of a writing option
  static String examTimestamp(String subject) {
    return 'timestamp-exam-$subject';
  }

  /// Saves if the shortcut dialog should be shown...
  static String get showShortCutDialog {
    return 'showShortCut';
  }

  /// Saves the initialPage...
  static String get initialPage {
    return 'initialPage';
  }

  /// Saves the work groups...
  static String get workGroups {
    return 'workGroups';
  }

  /// Saves the calendar...
  static String get calendar {
    return 'calendar';
  }

  /// Saves the version of the shown intro slides
  static String get slidesVersion {
    return 'slidesVersion';
  }

  /// Saves all subject names
  static String get subjects {
    return 'subjects';
  }

  /// Saves all room names
  static String get rooms {
    return 'rooms';
  }

  /// Saves all teacher names
  static String get teachers {
    return 'teachers';
  }

  /// Saves if the work groups should be shown in the timetable
  static String get showWorkGroupsInTimetable {
    return 'showWorkGroupsInTimetable';
  }

  /// Saves if the calendar should be shown in the timetable
  static String get showCalendarInTimetable {
    return 'showCalendarInTimetable';
  }

  /// Saves if the cafetoria should be shown in the timetable
  static String get showCafetoriaInTimetable {
    return 'showCafetoriaInTimetable';
  }

  /// Saves all updates dates
  static String get updates {
    return 'updates';
  }

  /// Saves is the timetable is updates
  static String get timetableIsNew {
    return 'timetableIsNew';
  }

  /// Saves the loaded nextcloud folder structure
  static String get nextcloud {
    return 'nextcloud';
  }
}
