// Defines all preferences keys...
class Keys {
  // Saves the selected grade...
  static String get grade {
    return 'grade';
  }

  static String get unitplanDate {
    return 'unitplanDate';
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

  // Saves if the replacementplan should be sorted...
  static String get sortReplacementPlan {
    return 'sortReplacementPlan';
  }

  // Saves if the replacemetplan should shown in the unitplan...
  static String get showReplacementPlanInUnitPlan {
    return 'showReplacementPlanInUnitPlan';
  }

  // Saves if the user get replacementplan notifications...
  static String get getReplacementPlanNotifications {
    return 'getReplacementPlanNotifications';
  }

  // unitPlan-GRADE saves the untiplan json string...
  // unitPLan-GRADE-BLOCK / uitplan-GRADE-DAY-UNIT saves the selected index...
  static String unitPlan(String grade, {String block, int day, int unit}) {
    // If nothing is set, returns the key for saving the json string...
    if (block == null && day == null) {
      return 'unitPlan-$grade';
    } else {
      return (block != '')
          ? 'unitPlan-$grade-$block'
          : 'unitPlan-$grade-$day-$unit';
    }
  }

  // replacementPlan-GRADE-DAY saves the replacement plan...
  static String replacementPlan(String grade, String day) {
    return 'replacementPlan-$grade-$day';
  }

  // exams-SUBJECTNAME saves if user writing exams in this course...
  static String exams(String grade, String subject) {
    return 'exams-$grade-$subject';
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

  static String historyDate(String type) {
    return 'historyDate-$type';
  }

  static String history(String type) {
    return 'history-$type';
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

  static String get showWorkGroupsInUnitPlan {
    return 'showWorkGroupsInUnitPlan';
  }

  static String get showCalendarInUnitPlan {
    return 'showCalendarInUnitPlan';
  }

  static String get showCafetoriaInUnitPlan {
    return 'showCafetoriaInUnitPlan';
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

  static String get unitPlanIsNew {
    return 'unitPlanIsNew';
  }

  static String get muteService {
    return 'muteService';
  }
}
