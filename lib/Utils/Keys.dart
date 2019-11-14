// Defines all preferences keys...
class Keys {
  // Saves the selected grade...
  static String get grade {
    return 'grade';
  }

  static String get group {
    return 'group';
  }

  static String get timetableDate {
    return 'timetableDate';
  }

  static String get daysLengths {
    return 'daysLengths';
  }

  static String get dev {
    return 'dev';
  }

  static String get bugs {
    return 'bugs';
  }

  static String get userId {
    return 'userId';
  }

  // Saves the two last selected grades...
  static String get lastGrades {
    return 'lastGrades';
  }

  // Saves the last notification received time...
  static String get lastUpdate {
    return 'lastUpdate';
  }

  // Saves the cafetoria data...
  static String get cafetoria {
    return 'cafetoria';
  }

  // Saves the keyfob id...
  static String get cafetoriaId {
    return 'cafetoriaUsername';
  }

  // Saves the keyfob password...
  static String get cafetoriaPassword {
    return 'cafetoriaPassword';
  }

  // Saves the app username...
  static String get username {
    return 'username';
  }

  // Saves the app password...
  static String get password {
    return 'password';
  }

  // Saves if the substitution plan should be sorted...
  static String get sortSubstitutionPlan {
    return 'sortSubstitutionPlan';
  }

  // Saves if the replacemetplan should shown in the timetable...
  static String get showSubstitutionPlanInTimetable {
    return 'showSubstitutionPlanInTimetable';
  }

  // Saves if the user get substitution plan notifications...
  static String get getSubstitutionPlanNotifications {
    return 'getSubstitutionPlanNotifications';
  }

  // timetable-GRADE saves the timetable json string...
  static String timetable(String grade) {
    return 'timetable-$grade';
  }

  // selection-courseID saves the selected course
  static String selection(String courseID) {
    return 'selection-$courseID';
  }

  // substitutionPlan saves the substitution plan...
  static String get substitutionPlan {
    return 'substitutionPlan';
  }

  // exams-courseID saves if user writing exams in this course...
  static String exams(String courseID) {
    return 'exams-$courseID';
  }

  // Saves if the shortcut dialog should be shown...
  static String get showShortCutDialog {
    return 'showShortCut';
  }

  // Saves the initialPage...
  static String get initialPage {
    return 'initialPage';
  }

  // Saves the work groups...
  static String get workGroups {
    return 'workGroups';
  }

  // Saves the calendar...
  static String get calendar {
    return 'calendar';
  }

  static String room(int weekday, int unit, String subject) {
    return 'room-' + weekday.toString() + '-' + unit.toString() + '-' + subject;
  }

  static String get slidesVersion {
    return 'slidesVersion';
  }

  static String get subjects {
    return 'subjects';
  }

  static String get rooms {
    return 'rooms';
  }

  static String get teachers {
    return 'teachers';
  }

  static String get showWorkGroupsInTimetable {
    return 'showWorkGroupsInTimetable';
  }

  static String get showCalendarInTimetable {
    return 'showCalendarInTimetable';
  }

  static String get showCafetoriaInTimetable {
    return 'showCafetoriaInTimetable';
  }

  static String get id {
    return 'id';
  }

  static String get updates {
    return 'updates';
  }

  static String get oldGrade {
    return 'oldGrade';
  }

  static String get timetableIsNew {
    return 'timetableIsNew';
  }

  static String get muteService {
    return 'muteService';
  }

  static String get lastModified {
    return 'lastModified';
  }
}
