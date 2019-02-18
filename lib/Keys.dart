// Defines all preferences keys...
class Keys {
  // Saves the selected grade...
  static String get grade {
    return 'grade';
  }

  static String get unitplanDate {
    return 'unitplanDate';
  }

  static String get dev {
    return 'dev';
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

  static String get messageboardGroups {
    return 'messageboardGroups';
  }

  static String messageboardFeed(int start, int end, List<String> groups) {
    return 'messageboardFeed-$start-$end-${groups.toString()}';
  }

  static String messageboardPosts(String name, int start, int end) {
    return 'messageboardPosts-$name-$start-$end';
  }

  static String get blockedGroups {
    return 'blockedGroups';
  }

  static String get loggedInGroups {
    return 'loggedInGroups';
  }

  static String get feedGroups {
    return 'feedGroups';
  }

  static String get notificationGroups {
    return 'notificationGroups';
  }

  static String get waitingGroups {
    return 'waitingGroups';
  }

  static String groupEditPassword(String group) {
    return 'groupEditPassword-$group';
  }

  static String messageboardGroupTag(String group) {
    return 'messageboard-${group.replaceAll(RegExp(r' '), '-')}';
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
}
