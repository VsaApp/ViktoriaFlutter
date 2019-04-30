import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, dynamic>> _localizedValues = {
    // List of all germans Strings...
    'de': {
      'title': 'Viktoria',
      'unitPlan': 'Stundenplan',
      'replacementPlan': 'Vertretungsplan',
      'pupil': 'Schüler*In',
      'teacher': 'Lehrer*In',
      'pleaseSelect': 'Bitte auswählen',
      'login': 'Anmelden',
      'checkLogin': 'Anmeldedaten überprüfen',
      'developerOptions': 'Entwickler',
      'fieldCantBeEmpty': 'Das Feld darf nicht leer sein',
      'pupilUsername': 'Nutzername der Homepage',
      'pupilPassword': 'Passwort der Homepage',
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
      'sortReplacementPlan': 'Sortieren',
      'showReplacementPlanInUnitPlan': 'Vertretungsplan anzeigen',
      'getReplacementPlanNotifications': 'Benachrichtigungen für Änderungen',
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
      'goOnlineToLogin': 'Du musst online sein, um dich anzumelden',
      'retry': 'Erneut versuchen',
      'oldDataIsShown': 'Alte Daten werden angezeigt, weil du offline bist',
      'serverIsOffline':
          'Alte Daten werden angezeigt, weil der Server offline ist',
      'failedToConnectToServer': 'Fehler beim verbinden zum Server',
      'ok': 'OK',
      'showShortCutDialog': 'Schnellstartdialog anzeigen',
      'initialPage': 'Startseite',
      'showReplacementPlanForBrotherSister':
          'Vertretungsplan für Geschwisterkind anzeigen',
      'noChanges': 'Keine Änderungen',
      'cafetoria': 'Cafetoria',
      'cafetoriaNoMenues': 'Keine Menüs vorhanden',
      'cafetoriaLogin': 'Keyfobdaten eingeben',
      'workGroups': 'AGs',
      'calendar': 'Kalender',
      'dates': 'Termine',
      'selectDate': 'Datum auswählen',
      'nowADeveloper': 'Du bist jetzt ein Entwickler!',
      'nowNoDeveloper': 'Du bist kein Entwickler mehr!',
      'replacementPlanUpdated': 'Neuer Vertretungsplan für %s',
      'goOnline': 'Du musst online sein beim ersten Mal laden!',
      'unparsed': 'Nicht erkannt',
      'yes': 'Ja',
      'no': 'Nein',
      'introUnitPlanTitle': 'Stundenplan',
      'newUnitplan': 'Neuer Stundenplan',
      'newUnitplanInfo':
          'Deine Fachauswahl und deine Schriftlichkeiten wurden zurückgesetzt, da es einen neuen Stundenplan gibt!',
      'introUnitPlanDescription':
          'Ein Blick in den Stundenplan zeigt dir eine vollständige Übersicht über deinen Tag mit allen Änderungen',
      'introReplacementPlanTitle': 'Vertretungsplan',
      'introReplacementPlanDescription':
          'Alle Vertretungen werden auf deine Stundenplan Auswahl angepasst und für dich gefiltert',
      'scanUnitPlan': 'Stundenplan scannen',
      'scanUnitPlanExplanation':
          'Du musst die Kamera deines Handys auf deinen Stundenplan halten und warten bis der Text erscheint. Wenn du meinst, dass alles erkannt wurde, dann kannst du einfach irgendwo auf den Bildschirm klicken. Danach musst du möglicherweise noch Fächer auswählen, wenn diese nicht erkannt werden konnten.',
      'scanUnitPlanAllDetected': 'Alles erkannt',
      'onlyOnline': 'Du kannst dies nur online tun!',
      'resetUnitPlan': 'Stundenplan zurücksetzen',
      'scanDescription':
      'Hier siehst du eine Liste der Stunden die beim Fotografieren nicht erkannt werden konnten. Wähle für jede Stunde immer deinen Kurs aus!',
      'year': 'Jahr',
      'month': 'Monat',
      'day': 'Tag',
      'time': 'Zeit',
      'replacementplanVersion': 'Vertretungsplan Version',
      'unitplanVersion': 'Stundenplan Version',
      'showWorkGroupsInUnitPlan': 'AGs anzeigen',
      'showCalendarInUnitPlan': 'Termine anzeigen',
      'event': 'Termin',
      'showCafetoriaInUnitPlan': 'Cafetoriamenüs anzeigen',
      'unitPlanSettings': 'Stundenplan',
      'replacementPlanSettings': 'Vertretungsplan',
      'loadNewestData': 'Aktuellste Version',
      'coursesLanguagesArts': 'Sprachlich-literarisch-künstlerisch',
      'coursesSocialScienes': 'Gesellschaftswissenschaftlich',
      'coursesNatureScienes': 'Mathematisch-naturwissenschaftlich-technisch',
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
      'introExtendedUnitplanTitle': 'Erweiterter Stundenplan',
      'introExtendedUnitplanDescription':
          'Zusätzlich zum Stundenplan kannst du dir auch alle AGs, alle Termine und alle Cafetoria Menüs für den jeweiligen Tag anzeigen lassen',
      'introCoursesTitle': 'Kurse',
      'introCoursesDescription':
          'Ändere Schriftlichkeiten für Klausuren oder überschreibe Räume',
      'introVsaAppTitle': 'VsaApp',
      'introVsaAppDescription': 'Viel Spaß beim Nutzen!',
      'viewIntro': 'Einführung nochmal anschauen',
      'loadOldData': 'Alte Daten laden?',
      'loadOldDataDescription':
      'Es werden die ausgewählten Stunden und die Schriftlichkeiten vom letzten Mal übernommen.',
      'cancel': 'Abbrechen',
      'introScannerTitle': 'Scanner',
      'oldApp':
      'Die aktuell installierte App Version (VERSION) ist zu alt und wird nicht mehr unterstützt.\n\nBitte sorge dafür, dass du die aktuelle App erhälst! Einfach im Store die aktuelle \'VsaApp\' installieren.',
      'accecptDseAndAgb':
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
      'failedToCheckLogin': 'Fehler beim überprüfen der Logindaten! Versuche es später erneut.',
      'unitAndReplacementplan': 'Stunden- und Vertretungsplan',
      'updated': ' aktualisiert',
      'updatedFailed': ' aktualisieren fehlgeschlagen'
    },
  };

// All getter defined...
  String get updated {
    return _localizedValues[locale.languageCode]['updated'];
  }

  String get unitAndReplacementplan {
    return _localizedValues[locale.languageCode]['unitAndReplacementplan'];
  }

  String get updatedFailed {
    return _localizedValues[locale.languageCode]['updatedFailed'];
  }

  String get failedToCheckLogin {
    return _localizedValues[locale.languageCode]['failedToCheckLogin'];
  }

  String get event {
    return _localizedValues[locale.languageCode]['event'];
  }

  String get scanDescription {
    return _localizedValues[locale.languageCode]['scanDescription'];
  }

  String get accept {
    return _localizedValues[locale.languageCode]['accept'];
  }

  String get accecptDseAndAgb {
    return _localizedValues[locale.languageCode]['accecptDseAndAgb'];
  }

  String get reject {
    return _localizedValues[locale.languageCode]['reject'];
  }

  String get readAgbDse {
    return _localizedValues[locale.languageCode]['readAgbDse'];
  }

  String get agbDse {
    return _localizedValues[locale.languageCode]['agbDse'];
  }

  String get appTooOld {
    return _localizedValues[locale.languageCode]['appTooOld'];
  }

  String get oldApp {
    return _localizedValues[locale.languageCode]['oldApp'];
  }

  String get loadOldData {
    return _localizedValues[locale.languageCode]['loadOldData'];
  }

  String get loadOldDataDescription {
    return _localizedValues[locale.languageCode]['loadOldDataDescription'];
  }

  String get aWeek {
    return _localizedValues[locale.languageCode]['aWeek'];
  }

  String get bWeek {
    return _localizedValues[locale.languageCode]['bWeek'];
  }

  String get loadNewestData {
    return _localizedValues[locale.languageCode]['loadNewestData'];
  }

  String get replacementplanVersion {
    return _localizedValues[locale.languageCode]['replacementplanVersion'];
  }

  String get unitplanVersion {
    return _localizedValues[locale.languageCode]['unitplanVersion'];
  }

  String get year {
    return _localizedValues[locale.languageCode]['year'];
  }

  String get month {
    return _localizedValues[locale.languageCode]['month'];
  }

  String get day {
    return _localizedValues[locale.languageCode]['day'];
  }

  String get time {
    return _localizedValues[locale.languageCode]['time'];
  }

  String get newUnitplan {
    return _localizedValues[locale.languageCode]['newUnitplan'];
  }

  String get selectDate {
    return _localizedValues[locale.languageCode]['selectDate'];
  }

  String get developerOptions {
    return _localizedValues[locale.languageCode]['developerOptions'];
  }

  String get newUnitplanInfo {
    return _localizedValues[locale.languageCode]['newUnitplanInfo'];
  }

  String get replacementPlanUpdated {
    return _localizedValues[locale.languageCode]['replacementPlanUpdated'];
  }

  String get unparsed {
    return _localizedValues[locale.languageCode]['unparsed'];
  }

  String get goOnline {
    return _localizedValues[locale.languageCode]['goOnline'];
  }

  String get failedToConnectToServer {
    return _localizedValues[locale.languageCode]['failedToConnectToServer'];
  }

  String get serverIsOffline {
    return _localizedValues[locale.languageCode]['serverIsOffline'];
  }

  String get yes {
    return _localizedValues[locale.languageCode]['yes'];
  }

  String get no {
    return _localizedValues[locale.languageCode]['no'];
  }

  String get cafetoria {
    return _localizedValues[locale.languageCode]['cafetoria'];
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

  String get introUnitPlanTitle {
    return _localizedValues[locale.languageCode]['introUnitPlanTitle'];
  }

  String get introUnitPlanDescription {
    return _localizedValues[locale.languageCode]['introUnitPlanDescription'];
  }

  String get introReplacementPlanTitle {
    return _localizedValues[locale.languageCode]['introReplacementPlanTitle'];
  }

  String get introReplacementPlanDescription {
    return _localizedValues[locale.languageCode]
        ['introReplacementPlanDescription'];
  }

  String get scanUnitPlan {
    return _localizedValues[locale.languageCode]['scanUnitPlan'];
  }

  String get scanUnitPlanExplanation {
    return _localizedValues[locale.languageCode]['scanUnitPlanExplanation'];
  }

  String get scanUnitPlanAllDetected {
    return _localizedValues[locale.languageCode]['scanUnitPlanAllDetected'];
  }

  String get resetUnitPlan {
    return _localizedValues[locale.languageCode]['resetUnitPlan'];
  }

  String get showWorkGroupsInUnitPlan {
    return _localizedValues[locale.languageCode]['showWorkGroupsInUnitPlan'];
  }

  String get showCalendarInUnitPlan {
    return _localizedValues[locale.languageCode]['showCalendarInUnitPlan'];
  }

  String get showCafetoriaInUnitPlan {
    return _localizedValues[locale.languageCode]['showCafetoriaInUnitPlan'];
  }

  String get unitPlanSettings {
    return _localizedValues[locale.languageCode]['unitPlanSettings'];
  }

  String get replacementPlanSettings {
    return _localizedValues[locale.languageCode]['replacementPlanSettings'];
  }

  String get coursesLanguagesArts {
    return _localizedValues[locale.languageCode]['coursesLanguagesArts'];
  }

  String get coursesSocialScienes {
    return _localizedValues[locale.languageCode]['coursesSocialScienes'];
  }

  String get coursesNatureScienes {
    return _localizedValues[locale.languageCode]['coursesNatureScienes'];
  }

  String get coursesOthers {
    return _localizedValues[locale.languageCode]['coursesOthers'];
  }

  String get subjects {
    return _localizedValues[locale.languageCode]['subjects'];
  }

  String get rooms {
    return _localizedValues[locale.languageCode]['rooms'];
  }

  String get teachers {
    return _localizedValues[locale.languageCode]['teachers'];
  }

  String get introCalendarTitle {
    return _localizedValues[locale.languageCode]['introCalendarTitle'];
  }

  String get introCalendarDescription {
    return _localizedValues[locale.languageCode]['introCalendarDescription'];
  }

  String get introCafetoriaTitle {
    return _localizedValues[locale.languageCode]['introCafetoriaTitle'];
  }

  String get introCafetoriaDescription {
    return _localizedValues[locale.languageCode]['introCafetoriaDescription'];
  }

  String get introWorkGroupsTitle {
    return _localizedValues[locale.languageCode]['introWorkGroupsTitle'];
  }

  String get introWorkGroupsDescription {
    return _localizedValues[locale.languageCode]['introWorkGroupsDescription'];
  }

  String get introNotificationsTitle {
    return _localizedValues[locale.languageCode]['introNotificationsTitle'];
  }

  String get introNotificationsDescription {
    return _localizedValues[locale.languageCode]
        ['introNotificationsDescription'];
  }

  String get introExtendedUnitplanTitle {
    return _localizedValues[locale.languageCode]['introExtendedUnitplanTitle'];
  }

  String get introExtendedUnitplanDescription {
    return _localizedValues[locale.languageCode]
        ['introExtendedUnitplanDescription'];
  }

  String get introCoursesTitle {
    return _localizedValues[locale.languageCode]['introCoursesTitle'];
  }

  String get introCoursesDescription {
    return _localizedValues[locale.languageCode]['introCoursesDescription'];
  }

  String get introVsaAppTitle {
    return _localizedValues[locale.languageCode]['introVsaAppTitle'];
  }

  String get introVsaAppDescription {
    return _localizedValues[locale.languageCode]['introVsaAppDescription'];
  }

  String get viewIntro {
    return _localizedValues[locale.languageCode]['viewIntro'];
  }

  String get cancel {
    return _localizedValues[locale.languageCode]['cancel'];
  }

  String get introScannerTitle {
    return _localizedValues[locale.languageCode]['introScannerTitle'];
  }

  String get introScannerDescription {
    return _localizedValues[locale.languageCode]['introScannerDescription'];
  }

  List<String> get months {
    return _localizedValues[locale.languageCode]['months'];
  }

  String get checkLogin {
    return _localizedValues[locale.languageCode]['checkLogin'];
  }

  String get syncPhone {
    return _localizedValues[locale.languageCode]['syncPhone'];
  }

  String get syncPhoneId {
    return _localizedValues[locale.languageCode]['syncPhoneId'];
  }

  String get syncPhoneDescription {
    return _localizedValues[locale.languageCode]['syncPhoneDescription'];
  }

  String get skip {
    return _localizedValues[locale.languageCode]['skip'];
  }

  List<String> get weekdays {
    return _localizedValues[locale.languageCode]['weekdays'];
  }

  String get notYetExistingOnServer {
    return _localizedValues[locale.languageCode]['notYetExistingOnServer'];
  }

  String get updates {
    return _localizedValues[locale.languageCode]['updates'];
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
