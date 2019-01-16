import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    // List of all germans Strings...
    'de': {
      'title': 'Viktoria',
      'unitPlan': 'Stundenplan',
      'replacementPlan': 'Vertretungsplan',
      'pupil': 'Schüler*In',
      'teacher': 'Lehrer*In',
      'pleaseSelect': 'Bitte auswählen',
      'login': 'Anmelden',
      'fieldCantBeEmpty': 'Das Feld darf nicht leer sein',
      'pupilUsername': 'Nutzername der Homepage',
      'pupilPassword': 'Passwort der Homepage',
      'teacherUsername': 'Kürzel',
      'teacherPassword': 'Passwort',
      'cafetoriaId': 'ID',
      'cafetoriaPassword': 'Pin',
      'notImplementedYet': 'Diese Funktion gibt es bislang noch nicht',
      'credentialsNotCorrect': 'Nutzername oder Passwort falsch',
      'lunchBreak': 'Mittagspause',
      'settings': 'Einstellungen',
      'personalData': 'PERSÖNLICHE DATEN',
      'appSettings': 'APPEINSTELLUNGEN',
      'logout': 'Abmelden',
      'freeLesson': 'Freistunde',
      'sortReplacementPlan': 'Vertretungsplan sortieren',
      'showReplacementPlanInUnitPlan':
          'Vertretungsplan im Stundenplan anzeigen',
      'getReplacementPlanNotifications':
          'Benachrichtigungen für Änderungen auf dem Vertretungsplan',
      'nUnit': '. Stunde',
      'myChanges': 'Meine Vertretungen',
      'undefChanges': 'Eventuell meine Vertretungen',
      'otherChanges': 'Weitere Vertretungen',
      'writeExams': 'Schriftlich',
      'writing': 'Schr.',
      'speaking': 'Mündl.',
      'courses': 'Meine Kurse',
      'selectLesson': 'Stunde auswählen',
      'noCourses': 'Es wurden noch keine Kurse ausgewählt!',
      'whatDoFirst': 'Was möchtest du als erstes machen?',
      'replacementplanFor': 'Vertretungsplan für ',
      'replacementplanThe': ', den ',
      'replacementplanLastUpdated': 'Zuletzt aktualisiert am ',
      'replacementplanAt': ' um ',
      'edit': 'Bearbeiten',
      'goOnlineToLogin': 'Du musst online sein um dich anzumelden',
      'retry': 'Erneut versuchen',
      'oldDataIsShown': 'Alte Daten werden angezeigt, weil du offline bist',
      'ok': 'OK',
      'showShortCutDialog': 'Schnellstartdialog anzeigen',
      'initialPage': 'Startseite',
      'showReplacementPlanForBrotherSister': 'Vertretungsplan für Geschwisterkind anzeigen',
      'noChanges': 'Keine Änderungen',
      'cafetoria': 'Cafetoria',
      'cafetoriaNoMenues': 'Keine Menüs vorhanden',
      'cafetoriaLogin': 'Keyfobdaten eingeben',
      'workGroups': 'AGs',
      'calendar': 'Kalender',
      'dates': 'Termine',
      'messageboard': 'Schwarzes Brett',
      'feed': 'Feed',
      'groups': 'Gruppen',
      'max3Groups': 'Du hast bereits 3 Gruppen ohne Bestätigung erstellt!',
      'noLoggedInGroup': 'Du bist noch in keiner Gruppe angemeldet!',
      'blockedInfo': ' (Blockiert)',
      'follow': 'Folgen',
      'doNotFollow': 'Entfolgen',
      'onlyOnline': 'Du kannst dies nur online tun!',
      'groupWaiting': 'Warte auf Bestätigung',
      'feedUpdated': 'Feed aktualisiert!',
      'noGroups': 'Du folgst noch keinen Gruppen!',
      'noPosts': 'Es gibt noch keine Posts für dich!',
      'groupInfo': 'Gruppeninformation',
      'noPostsAnymore': 'Es gibt keine weitern Posts!',
      'noPostsInGroup': 'Hier gibt es noch keine Posts!',
      'passwordChanged': 'Das Passwort wurde geändert!',
      'postGroup': 'Gruppe auswählen in der der Post gesendet werden soll',
      'postText': 'Post Text',
      'postTitle': 'Post Titel',
      'addPost': 'Post schreiben',
      'removeGroup': 'Gruppe löschen',
      'errorAddingGroup': 'Fehler beim Gruppe hinzufügen!',
      'addGroup': 'Gruppe erstellen',
      'groupName': 'Gruppen Name',
      'groupPassword': 'Gruppen Passwort',
      'addGroupInfo': 'Die Grupepe kannst erstmal nur du sehen, bis sie von den App-Entwicklern bestätigt wurde. Dies könnte etwas Zeit in anspruch nehmen.',
      'noSlash': '\'/\' ist nicht erlaubt',
      'groupAlreadyExist': 'Name ist schon vergeben',
      'passwordNotCorrect': 'Passwort falsch',
      'confirmDeleteGroup': 'Wollen sie wirklich die Gruppe löschen?',
      'confirmDeletePost': 'Wollen sie wirklich den Post löschen?',
      'removedGroup': 'Gruppe \'%s\' wurde gelöscht!',
      'editGroupInfo': 'Info bearbeiten',
      'editGroupPassword': 'Passwort bearbeiten',
      'errorEditGroup': 'Fehler beim bearbeiten der Gruppe!',
      'currentPassword': 'Aktuelles Passwort',
      'newPassword': 'Neues Passwort',
      'blockedAccepted': 'Gruppe wird ausgeblendet!',
      'group': 'Gruppe',
      'deletePost': 'Post löschen',
      'repeatNewPassword': 'Neues Passwort wiederholen',
      'passwordNotEqual': 'Die Passwörter sind unterschiedlich!',
      'noGroupsToShow': 'Es gibt aktuell noch keine Gruppen!\nDu kannst aber der erste sein der eine erstellt. Einfach unten rechts auf das Plus und dann auf das Gruppenzeichen klicken und schon kannst du eine Gruppe erstellen!',
      'nowADeveloper': 'Du bist jetzt ein Entwickler!',
      'nowNoDeveloper': 'Du bist kein Entwickler mehr!',
      'removedPost': 'Post gelöscht!',
      'yes': 'Ja',
      'no': 'Nein'
    },
  };

  // All getter defined...
  String get messageboard {
    return _localizedValues[locale.languageCode]['messageboard'];
  }

  String get confirmDeletePost {
    return _localizedValues[locale.languageCode]['confirmDeletePost'];
  }

  String get removedPost {
    return _localizedValues[locale.languageCode]['removedPost'];
  }

  String get blockedAccepted {
    return _localizedValues[locale.languageCode]['blockedAccepted'];
  }

  String get deletePost {
    return _localizedValues[locale.languageCode]['deletePost'];
  }

  String get group {
    return _localizedValues[locale.languageCode]['group'];
  }

  String get passwordNotEqual {
    return _localizedValues[locale.languageCode]['passwordNotEqual'];
  }

  String get currentPassword {
    return _localizedValues[locale.languageCode]['currentPassword'];
  }

  String get newPassword {
    return _localizedValues[locale.languageCode]['newPassword'];
  }

  String get repeatNewPassword {
    return _localizedValues[locale.languageCode]['repeatNewPassword'];
  }

  String get errorEditGroup {
    return _localizedValues[locale.languageCode]['errorEditGroup'];
  }

  String get editGroupInfo {
    return _localizedValues[locale.languageCode]['editGroupInfo'];
  }

  String get editGroupPassword {
    return _localizedValues[locale.languageCode]['editGroupPassword'];
  }

  String get removedGroup {
    return _localizedValues[locale.languageCode]['removedGroup'];
  }

  String get yes {
    return _localizedValues[locale.languageCode]['yes'];
  }

  String get no {
    return _localizedValues[locale.languageCode]['no'];
  }

  String get confirmDeleteGroup {
    return _localizedValues[locale.languageCode]['confirmDeleteGroup'];
  }

  String get removeGroup{
    return _localizedValues[locale.languageCode]['removeGroup'];
  }

  String get groupWaiting {
    return _localizedValues[locale.languageCode]['groupWaiting'];
  }

  String get groupName {
    return _localizedValues[locale.languageCode]['groupName'];
  }

  String get groupPassword {
    return _localizedValues[locale.languageCode]['groupPassword'];
  }

  String get passwordNotCorrect {
    return _localizedValues[locale.languageCode]['passwordNotCorrect'];
  }

  String get postText {
    return _localizedValues[locale.languageCode]['postText'];
  }

  String get postTitle {
    return _localizedValues[locale.languageCode]['postTitle'];
  }

  String get errorAddingGroup {
    return _localizedValues[locale.languageCode]['errorAddingGroup'];
  }

  String get addGroup {
    return _localizedValues[locale.languageCode]['addGroup'];
  }

  String get addGroupInfo {
    return _localizedValues[locale.languageCode]['addGroupInfo'];
  }

  String get noSlash {
    return _localizedValues[locale.languageCode]['noSlash'];
  }

  String get groupAlreadyExist {
    return _localizedValues[locale.languageCode]['groupAlreadyExist'];
  }

  String get feedUpdated {
    return _localizedValues[locale.languageCode]['feedUpdated'];
  }

  String get noGroups {
    return _localizedValues[locale.languageCode]['noGroups'];
  }

  String get noPosts {
    return _localizedValues[locale.languageCode]['noPosts'];
  }

  String get max3Groups {
    return _localizedValues[locale.languageCode]['max3Groups'];
  }

  String get noPostsAnymore {
    return _localizedValues[locale.languageCode]['noPostsAnymore'];
  }

  String get groupInfo {
    return _localizedValues[locale.languageCode]['groupInfo'];
  }

  String get passwordChanged {
    return _localizedValues[locale.languageCode]['passwordChanged'];
  }

  String get noPostsInGroup {
    return _localizedValues[locale.languageCode]['noPostsInGroup'];
  }

  String get addPost {
    return _localizedValues[locale.languageCode]['addPost'];
  }

  String get postGroup {
    return _localizedValues[locale.languageCode]['postGroup'];
  }

  String get noLoggedInGroup {
    return _localizedValues[locale.languageCode]['noLoggedInGroup'];
  }

  String get cafetoria {
    return _localizedValues[locale.languageCode]['cafetoria'];
  }

  String get feed {
    return _localizedValues[locale.languageCode]['feed'];
  }

  String get groups {
    return _localizedValues[locale.languageCode]['groups'];
  }

  String get noGroupsToShow {
    return _localizedValues[locale.languageCode]['noGroupsToShow'];
  }

  String get blockedInfo {
    return _localizedValues[locale.languageCode]['blockedInfo'];
  }

  String get follow {
    return _localizedValues[locale.languageCode]['follow'];
  }

  String get doNotFollow {
    return _localizedValues[locale.languageCode]['doNotFollow'];
  }

  String get onlyOnline {
    return _localizedValues[locale.languageCode]['onlyOnline'];
  }

  String get cafetoriaNoMenues {
    return _localizedValues[locale.languageCode]['cafetoriaNoMenues'];
  }

  String get noCourses {
    return _localizedValues[locale.languageCode]['noCourses'];
  }

  String get selectLesson {
    return _localizedValues[locale.languageCode]['selectLesson'];
  }

  String get courses {
    return _localizedValues[locale.languageCode]['courses'];
  }

  String get writing {
    return _localizedValues[locale.languageCode]['writing'];
  }

  String get speaking {
    return _localizedValues[locale.languageCode]['speaking'];
  }

  String get writeExams {
    return _localizedValues[locale.languageCode]['writeExams'];
  }

  String get myChanges {
    return _localizedValues[locale.languageCode]['myChanges'];
  }

  String get undefChanges {
    return _localizedValues[locale.languageCode]['undefChanges'];
  }

  String get otherChanges {
    return _localizedValues[locale.languageCode]['otherChanges'];
  }

  String get nUnit {
    return _localizedValues[locale.languageCode]['nUnit'];
  }

  String get sortReplacementPlan {
    return _localizedValues[locale.languageCode]['sortReplacementPlan'];
  }

  String get showReplacementPlanInUnitPlan {
    return _localizedValues[locale.languageCode]
        ['showReplacementPlanInUnitPlan'];
  }

  String get getReplacementPlanNotifications {
    return _localizedValues[locale.languageCode]
        ['getReplacementPlanNotifications'];
  }

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get unitPlan {
    return _localizedValues[locale.languageCode]['unitPlan'];
  }

  String get replacementPlan {
    return _localizedValues[locale.languageCode]['replacementPlan'];
  }

  String get pupil {
    return _localizedValues[locale.languageCode]['pupil'];
  }

  String get teacher {
    return _localizedValues[locale.languageCode]['teacher'];
  }

  String get pleaseSelect {
    return _localizedValues[locale.languageCode]['pleaseSelect'];
  }

  String get cafetoriaLogin {
    return _localizedValues[locale.languageCode]['cafetoriaLogin'];
  }

  String get login {
    return _localizedValues[locale.languageCode]['login'];
  }

  String get fieldCantBeEmpty {
    return _localizedValues[locale.languageCode]['fieldCantBeEmpty'];
  }

  String get pupilUsername {
    return _localizedValues[locale.languageCode]['pupilUsername'];
  }

  String get pupilPassword {
    return _localizedValues[locale.languageCode]['pupilPassword'];
  }

  String get teacherUsername {
    return _localizedValues[locale.languageCode]['teacherUsername'];
  }

  String get teacherPassword {
    return _localizedValues[locale.languageCode]['teacherPassword'];
  }

  String get cafetoriaId {
    return _localizedValues[locale.languageCode]['cafetoriaId'];
  }

  String get cafetoriaPassword {
    return _localizedValues[locale.languageCode]['cafetoriaPassword'];
  }

  String get notImplementedYet {
    return _localizedValues[locale.languageCode]['notImplementedYet'];
  }

  String get credentialsNotCorrect {
    return _localizedValues[locale.languageCode]['credentialsNotCorrect'];
  }

  String get lunchBreak {
    return _localizedValues[locale.languageCode]['lunchBreak'];
  }

  String get settings {
    return _localizedValues[locale.languageCode]['settings'];
  }

  String get personalData {
    return _localizedValues[locale.languageCode]['personalData'];
  }

  String get appSettings {
    return _localizedValues[locale.languageCode]['appSettings'];
  }

  String get logout {
    return _localizedValues[locale.languageCode]['logout'];
  }

  String get freeLesson {
    return _localizedValues[locale.languageCode]['freeLesson'];
  }

  String get whatDoFirst {
    return _localizedValues[locale.languageCode]['whatDoFirst'];
  }

  String get replacementplanFor {
    return _localizedValues[locale.languageCode]['replacementplanFor'];
  }

  String get replacementplanThe {
    return _localizedValues[locale.languageCode]['replacementplanThe'];
  }

  String get replacementplanLastUpdated {
    return _localizedValues[locale.languageCode]['replacementplanLastUpdated'];
  }

  String get replacementplanAt {
    return _localizedValues[locale.languageCode]['replacementplanAt'];
  }

  String get edit {
    return _localizedValues[locale.languageCode]['edit'];
  }

  String get goOnlineToLogin {
    return _localizedValues[locale.languageCode]['goOnlineToLogin'];
  }

  String get retry {
    return _localizedValues[locale.languageCode]['retry'];
  }

  String get oldDataIsShown {
    return _localizedValues[locale.languageCode]['oldDataIsShown'];
  }

  String get ok {
    return _localizedValues[locale.languageCode]['ok'];
  }

  String get showShortCutDialog {
    return _localizedValues[locale.languageCode]['showShortCutDialog'];
  }

  String get initialPage {
    return _localizedValues[locale.languageCode]['initialPage'];
  }

  String get showReplacementPlanForBrotherSister {
    return _localizedValues[locale.languageCode]
        ['showReplacementPlanForBrotherSister'];
  }

  String get noChanges {
    return _localizedValues[locale.languageCode]['noChanges'];
  }

  String get workGroups {
    return _localizedValues[locale.languageCode]['workGroups'];
  }

  String get calendar {
    return _localizedValues[locale.languageCode]['calendar'];
  }

  String get dates {
    return _localizedValues[locale.languageCode]['dates'];
  }

  String get nowADeveloper {
    return _localizedValues[locale.languageCode]['nowADeveloper'];
  }

  String get nowNoDeveloper {
    return _localizedValues[locale.languageCode]['nowNoDeveloper'];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
