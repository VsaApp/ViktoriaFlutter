import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
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
      'cafetoriaUsername': 'ID',
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
      'showReplacementPlanForBrotherSister':
          'Vertretungsplan für Geschwisterkind anzeigen',
      'noChanges': 'Keine Änderungen',
      'cafetoria': 'Cafetoria',
      'cafetoriaNoMenues': 'Es gibt keine Menüs für diesen Tag',
      'cafetoriaLogin': 'Keyfobdaten eingeben',
      'workGroups': 'AGs'
    },
  };

  String get cafetoria {
    return _localizedValues[locale.languageCode]['cafetoria'];
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

  String get cafetoriaUsername {
    return _localizedValues[locale.languageCode]['cafetoriaUsername'];
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
