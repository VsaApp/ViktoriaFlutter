import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

/// Defines all shown string for the supported languages
class AppLocalizations {
  // ignore: public_member_api_docs
  AppLocalizations(this.locale);

  /// The user language
  final Locale locale;

  /// Get the language list for the user language
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Map of all languages and strings
  static final Map<String, Map<String, dynamic>> _localizedValues = {
    // List of all germans Strings...
    'de': {
      'title': 'Viktoria',
      'timetable': 'Stundenplan',
      'substitutionPlan': 'Vertretungsplan',
      'pupil': 'Schüler*In',
      'teacher': 'Lehrer*In',
      'pleaseSelect': 'Bitte auswählen',
      'login': 'Anmelden',
      'checkLogin': 'Anmeldedaten überprüfen',
      'developerOptions': 'Entwickler',
      'fieldCantBeEmpty': 'Das Feld darf nicht leer sein',
      'pupilUsername': 'Nutzername der Schul-PCs',
      'pupilPassword': 'Passwort der Schule-PCs',
      'teacherUsername': 'Kürzel',
      'teacherPassword': 'Passwort',
      'cafetoriaId': 'ID',
      'cafetoriaPassword': 'Pin',
      'credentialsNotCorrect': 'Nutzername oder Passwort falsch',
      'lunchBreak': 'Mittagspause',
      'settings': 'Einstellungen',
      'personalData': 'Persönliche Daten',
      'appSettings': 'App',
      'logout': 'Abmelden',
      'freeLesson': 'Freistunde',
      'showSubstitutionPlanInTimetable': 'Vertretungsplan anzeigen',
      'getSubstitutionPlanNotifications': 'Benachrichtigungen für Änderungen',
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
      'substitutionPlanFor': 'Vertretungsplan für ',
      'substitutionPlanThe': ', den ',
      'substitutionPlanLastUpdated': 'Zuletzt aktualisiert am ',
      'substitutionPlanAt': ' um ',
      'edit': 'Bearbeiten',
      'goOnlineToLogin': 'Du musst online sein, um dich anzumelden',
      'retry': 'Erneut versuchen',
      'oldDataIsShown': 'Alte Daten werden angezeigt, weil du offline bist',
      'serverIsOffline':
          'Alte Daten werden angezeigt, weil der Server offline ist',
      'failedToConnectToServer': 'Fehler beim verbinden zum Server',
      'ok': 'OK',
      'showShortCutDialog': 'Schnellstartdialog anzeigen',
      'initialPage': 'Startseite',
      'showSubstitutionPlanForBrotherSister':
          'Vertretungsplan für Geschwisterkind anzeigen',
      'noChanges': 'Keine Änderungen',
      'cafetoria': 'Cafetoria',
      'cafetoriaNoMenus': 'Keine Menüs vorhanden',
      'cafetoriaLogin': 'Keyfob-Daten eingeben',
      'workGroups': 'AGs',
      'calendar': 'Kalender',
      'dates': 'Termine',
      'selectDate': 'Datum auswählen',
      'nowADeveloper': 'Du bist jetzt ein Entwickler!',
      'nowNoDeveloper': 'Du bist kein Entwickler mehr!',
      'substitutionPlanUpdated': 'Neuer Vertretungsplan für %s',
      'goOnline': 'Du musst online sein beim ersten Mal laden!',
      'unparsed': 'Nicht erkannt',
      'yes': 'Ja',
      'no': 'Nein',
      'introTimetableTitle': 'Stundenplan',
      'newTimetable': 'Neuer Stundenplan',
      'newTimetableInfo':
          'Deine Fachauswahl und deine Schriftlichkeiten wurden zurückgesetzt, da es einen neuen Stundenplan gibt!',
      'introTimetableDescription':
          'Ein Blick in den Stundenplan zeigt dir eine vollständige Übersicht über deinen Tag mit allen Änderungen',
      'introSubstitutionPlanTitle': 'Vertretungsplan',
      'introSubstitutionPlanDescription':
          'Alle Vertretungen werden auf deine Stundenplan Auswahl angepasst und für dich gefiltert',
      'scanTimetable': 'Stundenplan scannen',
      'scanTimetableExplanation':
          'Du musst die Kamera deines Handys auf deinen Stundenplan halten und warten bis der Text erscheint. Wenn du meinst, dass alles erkannt wurde, dann kannst du einfach irgendwo auf den Bildschirm klicken. Danach musst du möglicherweise noch Fächer auswählen, wenn diese nicht erkannt werden konnten.',
      'scanTimetableAllDetected': 'Alles erkannt',
      'onlyOnline': 'Du kannst dies nur online tun!',
      'resetTimetable': 'Stundenplan zurücksetzen',
      'scanDescription':
          'Hier siehst du eine Liste der Stunden die beim Fotografieren nicht erkannt werden konnten. Wähle für jede Stunde immer deinen Kurs aus!',
      'year': 'Jahr',
      'month': 'Monat',
      'day': 'Tag',
      'time': 'Zeit',
      'substitutionPlanVersion': 'Vertretungsplan Version',
      'timetableVersion': 'Stundenplan Version',
      'showWorkGroupsInTimetable': 'AGs anzeigen',
      'showCalendarInTimetable': 'Termine anzeigen',
      'event': 'Termin',
      'showCafetoriaInTimetable': 'Cafetoriamenüs anzeigen',
      'timetableSettings': 'Stundenplan',
      'substitutionPlanSettings': 'Vertretungsplan',
      'loadNewestData': 'Aktuellste Version',
      'coursesLanguagesArts': 'Sprachlich-literarisch-künstlerisch',
      'coursesSocialSciences': 'Gesellschaftswissenschaftlich',
      'coursesNatureSciences': 'Mathematisch-naturwissenschaftlich-technisch',
      'coursesOthers': 'Sonstige',
      'subjects': 'Fächer',
      'rooms': 'Räume',
      'teachers': 'Lehrer*innen',
      'introCalendarTitle': 'Kalender',
      'introCalendarDescription':
          'Alle Termine der Schule und Feiertage werden dir übersichtlich angezeigt',
      'introCafetoriaTitle': 'Cafetoria',
      'introCafetoriaDescription':
          'Sieh dir die Menüs an und überprüfe direkt wie viel Geld du noch hast',
      'introWorkGroupsTitle': 'AGs',
      'introWorkGroupsDescription':
          'Du kannst alle AGs der Schule direkt auf einen Blick sehen',
      'aWeek': 'A-Woche:',
      'bWeek': 'B-Woche:',
      'introNotificationsTitle': 'Benachrichtigungen',
      'introNotificationsDescription':
          'Erhalte personalisierte Benachrichtigungen Vertretungs- und Stundenplanänderungen',
      'introExtendedTimetableTitle': 'Erweiterter Stundenplan',
      'introExtendedTimetableDescription':
          'Zusätzlich zum Stundenplan kannst du dir auch alle AGs, alle Termine und alle Cafetoria Menüs für den jeweiligen Tag anzeigen lassen',
      'introCoursesTitle': 'Kurse',
      'introCoursesDescription':
          'Ändere Schriftlichkeiten für Klausuren oder überschreibe Räume',
      'introVsaAppTitle': 'VsaApp',
      'introVsaAppDescription': 'Viel Spaß beim Nutzen!',
      'viewIntro': 'Einführung nochmal anschauen',
      'cancel': 'Abbrechen',
      'introScannerTitle': 'Scanner',
      'oldApp':
          'Die aktuell installierte App Version (VERSION) ist zu alt und wird nicht mehr unterstützt.\n\nBitte sorge dafür, dass du die aktuelle App erhältst! Einfach im Store die aktuelle \'VsaApp\' installieren.',
      'acceptDseAndAgb':
          'Mit der Nutzung unserer App akzeptierst du unsere AGB und unsere Datenschutzerklärung.',
      'accept': 'Akzeptieren',
      'reject': 'Ablehnen',
      'readAgbDse': 'AGB/DSE Lesen',
      'agbDse': 'AGB/DSE',
      'appTooOld': 'App zu alt!',
      'introScannerDescription':
          'Damit du nicht deinen ganzen Stundenplan von Hand eingeben musst, kannst du ihn auch einfach mit deinem Handy einscannen',
      'months': [
        'Januar',
        'Februar',
        'März',
        'April',
        'Mai',
        'Juni',
        'Juli',
        'August',
        'September',
        'Oktober',
        'November',
        'Dezember',
      ],
      'syncPhoneId': 'Synchronisierungs-ID',
      'syncPhone': 'Mit Handy synchronisieren',
      'syncPhoneDescription':
          'Wenn du auf deinem Handy und in dieser Anwendung immer dieselben Sachen sehen möchtest, dann musst die Synchronisierungs-ID aus deine Einstellungen deiner App nehmen und hier eingeben:',
      'skip': 'Überspringen',
      'weekdays': [
        'Montag',
        'Dienstag',
        'Mittwoch',
        'Donnerstag',
        'Freitag',
      ],
      'notYetExistingOnServer': 'Noch nicht auf dem Schulserver vorhanden!',
      'updates': 'Aktualisierungen',
      'failedToCheckLogin':
          'Fehler beim überprüfen der Logindaten! Versuche es später erneut.',
      'unitAndSubstitutionPlan': 'Stunden- und Vertretungsplan',
      'updated': ' aktualisiert',
      'cloud': 'Cloud',
      'updatedFailed': ' aktualisieren fehlgeschlagen',
      'exam': 'Klausur',
      'delete': 'Löschen',
      'rename': 'Umbenennen',
      'share': 'Teilen',
      'download': 'Herunterladen',
      'details': 'Details',
      'file': 'Datei',
      'folder': 'Ordner',
      'newDirectory': 'Neuer Ordner',
    },
  };
  // ignore: public_member_api_docs
  String gradeName(String grade) {
    return !['ef', 'q1', 'q1'].contains(grade) ? grade : grade.toUpperCase();
  }

  // All getter defined...
  // ignore: public_member_api_docs
  String get newDirectory {
    return _localizedValues[locale.languageCode]['newDirectory'];
  }

  // ignore: public_member_api_docs
  String get details {

    return _localizedValues[locale.languageCode]['details'];
  }

  // ignore: public_member_api_docs
  String get file {

    return _localizedValues[locale.languageCode]['file'];
  }

  // ignore: public_member_api_docs
  String get folder {

    return _localizedValues[locale.languageCode]['folder'];
  }

  // ignore: public_member_api_docs
  String get delete {

    return _localizedValues[locale.languageCode]['delete'];
  }

  // ignore: public_member_api_docs
  String get rename {

    return _localizedValues[locale.languageCode]['rename'];
  }

  // ignore: public_member_api_docs
  String get share {

    return _localizedValues[locale.languageCode]['share'];
  }

  // ignore: public_member_api_docs
  String get download {

    return _localizedValues[locale.languageCode]['download'];
  }

  // ignore: public_member_api_docs
  String get cloud {

    return _localizedValues[locale.languageCode]['cloud'];
  }

  // ignore: public_member_api_docs
  String get updated {

    return _localizedValues[locale.languageCode]['updated'];
  }

  // ignore: public_member_api_docs
  String get exam {

    return _localizedValues[locale.languageCode]['exam'];
  }

  // ignore: public_member_api_docs
  String get unitAndSubstitutionPlan {

    return _localizedValues[locale.languageCode]['unitAndSubstitutionPlan'];
  }

  // ignore: public_member_api_docs
  String get updatedFailed {

    return _localizedValues[locale.languageCode]['updatedFailed'];
  }

  // ignore: public_member_api_docs
  String get failedToCheckLogin {

    return _localizedValues[locale.languageCode]['failedToCheckLogin'];
  }

  // ignore: public_member_api_docs
  String get event {

    return _localizedValues[locale.languageCode]['event'];
  }

  // ignore: public_member_api_docs
  String get scanDescription {

    return _localizedValues[locale.languageCode]['scanDescription'];
  }

  // ignore: public_member_api_docs
  String get accept {

    return _localizedValues[locale.languageCode]['accept'];
  }

  // ignore: public_member_api_docs
  String get acceptDseAndAgb {

    return _localizedValues[locale.languageCode]['acceptDseAndAgb'];
  }

  // ignore: public_member_api_docs
  String get reject {

    return _localizedValues[locale.languageCode]['reject'];
  }

  // ignore: public_member_api_docs
  String get readAgbDse {

    return _localizedValues[locale.languageCode]['readAgbDse'];
  }

  // ignore: public_member_api_docs
  String get agbDse {

    return _localizedValues[locale.languageCode]['agbDse'];
  }

  // ignore: public_member_api_docs
  String get appTooOld {

    return _localizedValues[locale.languageCode]['appTooOld'];
  }

  // ignore: public_member_api_docs
  String get oldApp {

    return _localizedValues[locale.languageCode]['oldApp'];
  }

  // ignore: public_member_api_docs
  String get aWeek {

    return _localizedValues[locale.languageCode]['aWeek'];
  }

  // ignore: public_member_api_docs
  String get bWeek {

    return _localizedValues[locale.languageCode]['bWeek'];
  }

  // ignore: public_member_api_docs
  String get loadNewestData {

    return _localizedValues[locale.languageCode]['loadNewestData'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanVersion {

    return _localizedValues[locale.languageCode]['substitutionPlanVersion'];
  }

  // ignore: public_member_api_docs
  String get timetableVersion {

    return _localizedValues[locale.languageCode]['timetableVersion'];
  }

  // ignore: public_member_api_docs
  String get year {

    return _localizedValues[locale.languageCode]['year'];
  }

  // ignore: public_member_api_docs
  String get month {

    return _localizedValues[locale.languageCode]['month'];
  }

  // ignore: public_member_api_docs
  String get day {

    return _localizedValues[locale.languageCode]['day'];
  }

  // ignore: public_member_api_docs
  String get time {

    return _localizedValues[locale.languageCode]['time'];
  }

  // ignore: public_member_api_docs
  String get newTimetable {

    return _localizedValues[locale.languageCode]['newTimetable'];
  }

  // ignore: public_member_api_docs
  String get selectDate {

    return _localizedValues[locale.languageCode]['selectDate'];
  }

  // ignore: public_member_api_docs
  String get developerOptions {

    return _localizedValues[locale.languageCode]['developerOptions'];
  }

  // ignore: public_member_api_docs
  String get newTimetableInfo {

    return _localizedValues[locale.languageCode]['newTimetableInfo'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanUpdated {

    return _localizedValues[locale.languageCode]['substitutionPlanUpdated'];
  }

  // ignore: public_member_api_docs
  String get unparsed {

    return _localizedValues[locale.languageCode]['unparsed'];
  }

  // ignore: public_member_api_docs
  String get goOnline {

    return _localizedValues[locale.languageCode]['goOnline'];
  }

  // ignore: public_member_api_docs
  String get failedToConnectToServer {

    return _localizedValues[locale.languageCode]['failedToConnectToServer'];
  }

  // ignore: public_member_api_docs
  String get serverIsOffline {

    return _localizedValues[locale.languageCode]['serverIsOffline'];
  }

  // ignore: public_member_api_docs
  String get yes {

    return _localizedValues[locale.languageCode]['yes'];
  }

  // ignore: public_member_api_docs
  String get no {

    return _localizedValues[locale.languageCode]['no'];
  }

  // ignore: public_member_api_docs
  String get cafetoria {

    return _localizedValues[locale.languageCode]['cafetoria'];
  }

  // ignore: public_member_api_docs
  String get onlyOnline {

    return _localizedValues[locale.languageCode]['onlyOnline'];
  }

  // ignore: public_member_api_docs
  String get cafetoriaNoMenus {

    return _localizedValues[locale.languageCode]['cafetoriaNoMenus'];
  }

  // ignore: public_member_api_docs
  String get noCourses {

    return _localizedValues[locale.languageCode]['noCourses'];
  }

  // ignore: public_member_api_docs
  String get selectLesson {

    return _localizedValues[locale.languageCode]['selectLesson'];
  }

  // ignore: public_member_api_docs
  String get courses {

    return _localizedValues[locale.languageCode]['courses'];
  }

  // ignore: public_member_api_docs
  String get writing {

    return _localizedValues[locale.languageCode]['writing'];
  }

  // ignore: public_member_api_docs
  String get speaking {

    return _localizedValues[locale.languageCode]['speaking'];
  }

  // ignore: public_member_api_docs
  String get writeExams {

    return _localizedValues[locale.languageCode]['writeExams'];
  }

  // ignore: public_member_api_docs
  String get myChanges {

    return _localizedValues[locale.languageCode]['myChanges'];
  }

  // ignore: public_member_api_docs
  String get undefChanges {

    return _localizedValues[locale.languageCode]['undefChanges'];
  }

  // ignore: public_member_api_docs
  String get otherChanges {

    return _localizedValues[locale.languageCode]['otherChanges'];
  }

  // ignore: public_member_api_docs
  String get nUnit {

    return _localizedValues[locale.languageCode]['nUnit'];
  }

  // ignore: public_member_api_docs
  String get showSubstitutionPlanInTimetable {

    return _localizedValues[locale.languageCode]
        ['showSubstitutionPlanInTimetable'];
  }

  // ignore: public_member_api_docs
  String get getSubstitutionPlanNotifications {

    return _localizedValues[locale.languageCode]
        ['getSubstitutionPlanNotifications'];
  }

  // ignore: public_member_api_docs
  String get title {

    return _localizedValues[locale.languageCode]['title'];
  }

  // ignore: public_member_api_docs
  String get timetable {

    return _localizedValues[locale.languageCode]['timetable'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlan {

    return _localizedValues[locale.languageCode]['substitutionPlan'];
  }

  // ignore: public_member_api_docs
  String get pupil {

    return _localizedValues[locale.languageCode]['pupil'];
  }

  // ignore: public_member_api_docs
  String get teacher {

    return _localizedValues[locale.languageCode]['teacher'];
  }

  // ignore: public_member_api_docs
  String get pleaseSelect {

    return _localizedValues[locale.languageCode]['pleaseSelect'];
  }

  // ignore: public_member_api_docs
  String get cafetoriaLogin {

    return _localizedValues[locale.languageCode]['cafetoriaLogin'];
  }

  // ignore: public_member_api_docs
  String get login {

    return _localizedValues[locale.languageCode]['login'];
  }

  // ignore: public_member_api_docs
  String get fieldCantBeEmpty {

    return _localizedValues[locale.languageCode]['fieldCantBeEmpty'];
  }

  // ignore: public_member_api_docs
  String get pupilUsername {

    return _localizedValues[locale.languageCode]['pupilUsername'];
  }

  // ignore: public_member_api_docs
  String get pupilPassword {

    return _localizedValues[locale.languageCode]['pupilPassword'];
  }

  // ignore: public_member_api_docs
  String get teacherUsername {

    return _localizedValues[locale.languageCode]['teacherUsername'];
  }

  // ignore: public_member_api_docs
  String get teacherPassword {

    return _localizedValues[locale.languageCode]['teacherPassword'];
  }

  // ignore: public_member_api_docs
  String get cafetoriaId {

    return _localizedValues[locale.languageCode]['cafetoriaId'];
  }

  // ignore: public_member_api_docs
  String get cafetoriaPassword {

    return _localizedValues[locale.languageCode]['cafetoriaPassword'];
  }

  // ignore: public_member_api_docs
  String get credentialsNotCorrect {

    return _localizedValues[locale.languageCode]['credentialsNotCorrect'];
  }

  // ignore: public_member_api_docs
  String get lunchBreak {

    return _localizedValues[locale.languageCode]['lunchBreak'];
  }

  // ignore: public_member_api_docs
  String get settings {

    return _localizedValues[locale.languageCode]['settings'];
  }

  // ignore: public_member_api_docs
  String get personalData {

    return _localizedValues[locale.languageCode]['personalData'];
  }

  // ignore: public_member_api_docs
  String get appSettings {

    return _localizedValues[locale.languageCode]['appSettings'];
  }

  // ignore: public_member_api_docs
  String get logout {

    return _localizedValues[locale.languageCode]['logout'];
  }

  // ignore: public_member_api_docs
  String get freeLesson {

    return _localizedValues[locale.languageCode]['freeLesson'];
  }

  // ignore: public_member_api_docs
  String get whatDoFirst {

    return _localizedValues[locale.languageCode]['whatDoFirst'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanFor {

    return _localizedValues[locale.languageCode]['substitutionPlanFor'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanThe {

    return _localizedValues[locale.languageCode]['substitutionPlanThe'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanLastUpdated {

    return _localizedValues[locale.languageCode]['substitutionPlanLastUpdated'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanAt {

    return _localizedValues[locale.languageCode]['substitutionPlanAt'];
  }

  // ignore: public_member_api_docs
  String get edit {

    return _localizedValues[locale.languageCode]['edit'];
  }

  // ignore: public_member_api_docs
  String get goOnlineToLogin {

    return _localizedValues[locale.languageCode]['goOnlineToLogin'];
  }

  // ignore: public_member_api_docs
  String get retry {

    return _localizedValues[locale.languageCode]['retry'];
  }

  // ignore: public_member_api_docs
  String get oldDataIsShown {

    return _localizedValues[locale.languageCode]['oldDataIsShown'];
  }

  // ignore: public_member_api_docs
  String get ok {

    return _localizedValues[locale.languageCode]['ok'];
  }

  // ignore: public_member_api_docs
  String get showShortCutDialog {

    return _localizedValues[locale.languageCode]['showShortCutDialog'];
  }

  // ignore: public_member_api_docs
  String get initialPage {

    return _localizedValues[locale.languageCode]['initialPage'];
  }

  // ignore: public_member_api_docs
  String get showSubstitutionPlanForBrotherSister {

    return _localizedValues[locale.languageCode]
        ['showSubstitutionPlanForBrotherSister'];
  }

  // ignore: public_member_api_docs
  String get noChanges {

    return _localizedValues[locale.languageCode]['noChanges'];
  }

  // ignore: public_member_api_docs
  String get workGroups {

    return _localizedValues[locale.languageCode]['workGroups'];
  }

  // ignore: public_member_api_docs
  String get calendar {

    return _localizedValues[locale.languageCode]['calendar'];
  }

  // ignore: public_member_api_docs
  String get dates {

    return _localizedValues[locale.languageCode]['dates'];
  }

  // ignore: public_member_api_docs
  String get nowADeveloper {

    return _localizedValues[locale.languageCode]['nowADeveloper'];
  }

  // ignore: public_member_api_docs
  String get nowNoDeveloper {

    return _localizedValues[locale.languageCode]['nowNoDeveloper'];
  }

  // ignore: public_member_api_docs
  String get introTimetableTitle {

    return _localizedValues[locale.languageCode]['introTimetableTitle'];
  }

  // ignore: public_member_api_docs
  String get introTimetableDescription {

    return _localizedValues[locale.languageCode]['introTimetableDescription'];
  }

  // ignore: public_member_api_docs
  String get introSubstitutionPlanTitle {

    return _localizedValues[locale.languageCode]['introSubstitutionPlanTitle'];
  }

  // ignore: public_member_api_docs
  String get introSubstitutionPlanDescription {

    return _localizedValues[locale.languageCode]
        ['introSubstitutionPlanDescription'];
  }

  // ignore: public_member_api_docs
  String get scanTimetable {

    return _localizedValues[locale.languageCode]['scanTimetable'];
  }

  // ignore: public_member_api_docs
  String get scanTimetableExplanation {

    return _localizedValues[locale.languageCode]['scanTimetableExplanation'];
  }

  // ignore: public_member_api_docs
  String get scanTimetableAllDetected {

    return _localizedValues[locale.languageCode]['scanTimetableAllDetected'];
  }

  // ignore: public_member_api_docs
  String get resetTimetable {

    return _localizedValues[locale.languageCode]['resetTimetable'];
  }

  // ignore: public_member_api_docs
  String get showWorkGroupsInTimetable {

    return _localizedValues[locale.languageCode]['showWorkGroupsInTimetable'];
  }

  // ignore: public_member_api_docs
  String get showCalendarInTimetable {

    return _localizedValues[locale.languageCode]['showCalendarInTimetable'];
  }

  // ignore: public_member_api_docs
  String get showCafetoriaInTimetable {

    return _localizedValues[locale.languageCode]['showCafetoriaInTimetable'];
  }

  // ignore: public_member_api_docs
  String get timetableSettings {

    return _localizedValues[locale.languageCode]['timetableSettings'];
  }

  // ignore: public_member_api_docs
  String get substitutionPlanSettings {

    return _localizedValues[locale.languageCode]['substitutionPlanSettings'];
  }

  // ignore: public_member_api_docs
  String get coursesLanguagesArts {

    return _localizedValues[locale.languageCode]['coursesLanguagesArts'];
  }

  // ignore: public_member_api_docs
  String get coursesSocialSciences {

    return _localizedValues[locale.languageCode]['coursesSocialSciences'];
  }

  // ignore: public_member_api_docs
  String get coursesNatureSciences {

    return _localizedValues[locale.languageCode]['coursesNatureSciences'];
  }

  // ignore: public_member_api_docs
  String get coursesOthers {

    return _localizedValues[locale.languageCode]['coursesOthers'];
  }

  // ignore: public_member_api_docs
  String get subjects {

    return _localizedValues[locale.languageCode]['subjects'];
  }

  // ignore: public_member_api_docs
  String get rooms {

    return _localizedValues[locale.languageCode]['rooms'];
  }

  // ignore: public_member_api_docs
  String get teachers {

    return _localizedValues[locale.languageCode]['teachers'];
  }

  // ignore: public_member_api_docs
  String get introCalendarTitle {

    return _localizedValues[locale.languageCode]['introCalendarTitle'];
  }

  // ignore: public_member_api_docs
  String get introCalendarDescription {

    return _localizedValues[locale.languageCode]['introCalendarDescription'];
  }

  // ignore: public_member_api_docs
  String get introCafetoriaTitle {

    return _localizedValues[locale.languageCode]['introCafetoriaTitle'];
  }

  // ignore: public_member_api_docs
  String get introCafetoriaDescription {

    return _localizedValues[locale.languageCode]['introCafetoriaDescription'];
  }

  // ignore: public_member_api_docs
  String get introWorkGroupsTitle {

    return _localizedValues[locale.languageCode]['introWorkGroupsTitle'];
  }

  // ignore: public_member_api_docs
  String get introWorkGroupsDescription {

    return _localizedValues[locale.languageCode]['introWorkGroupsDescription'];
  }

  // ignore: public_member_api_docs
  String get introNotificationsTitle {

    return _localizedValues[locale.languageCode]['introNotificationsTitle'];
  }

  // ignore: public_member_api_docs
  String get introNotificationsDescription {

    return _localizedValues[locale.languageCode]
        ['introNotificationsDescription'];
  }

  // ignore: public_member_api_docs
  String get introExtendedTimetableTitle {

    return _localizedValues[locale.languageCode]['introExtendedTimetableTitle'];
  }

  // ignore: public_member_api_docs
  String get introExtendedTimetableDescription {

    return _localizedValues[locale.languageCode]
        ['introExtendedTimetableDescription'];
  }

  // ignore: public_member_api_docs
  String get introCoursesTitle {

    return _localizedValues[locale.languageCode]['introCoursesTitle'];
  }

  // ignore: public_member_api_docs
  String get introCoursesDescription {

    return _localizedValues[locale.languageCode]['introCoursesDescription'];
  }

  // ignore: public_member_api_docs
  String get introVsaAppTitle {

    return _localizedValues[locale.languageCode]['introVsaAppTitle'];
  }

  // ignore: public_member_api_docs
  String get introVsaAppDescription {

    return _localizedValues[locale.languageCode]['introVsaAppDescription'];
  }

  // ignore: public_member_api_docs
  String get viewIntro {

    return _localizedValues[locale.languageCode]['viewIntro'];
  }

  // ignore: public_member_api_docs
  String get cancel {

    return _localizedValues[locale.languageCode]['cancel'];
  }

  // ignore: public_member_api_docs
  String get introScannerTitle {

    return _localizedValues[locale.languageCode]['introScannerTitle'];
  }

  // ignore: public_member_api_docs
  String get introScannerDescription {

    return _localizedValues[locale.languageCode]['introScannerDescription'];
  }

  // ignore: public_member_api_docs
  List<String> get months {
    return _localizedValues[locale.languageCode]['months'];
  }

  // ignore: public_member_api_docs
  String get checkLogin {

    return _localizedValues[locale.languageCode]['checkLogin'];
  }

  // ignore: public_member_api_docs
  String get syncPhone {

    return _localizedValues[locale.languageCode]['syncPhone'];
  }

  // ignore: public_member_api_docs
  String get syncPhoneId {

    return _localizedValues[locale.languageCode]['syncPhoneId'];
  }

  // ignore: public_member_api_docs
  String get syncPhoneDescription {

    return _localizedValues[locale.languageCode]['syncPhoneDescription'];
  }

  // ignore: public_member_api_docs
  String get skip {

    return _localizedValues[locale.languageCode]['skip'];
  }

  // ignore: public_member_api_docs
  List<String> get weekdays {
    return _localizedValues[locale.languageCode]['weekdays'];
  }

  // ignore: public_member_api_docs
  String get notYetExistingOnServer {

    return _localizedValues[locale.languageCode]['notYetExistingOnServer'];
  }

  // ignore: public_member_api_docs
  String get updates {

    return _localizedValues[locale.languageCode]['updates'];
  }
}

// ignore: public_member_api_docs
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // ignore: public_member_api_docs
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
