import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Errors.dart' as bugs;

import 'Intro/IntroPage.dart';
import 'Loading/LoadingPage.dart';
import 'Login/LoginPage.dart';
import 'MainFrame/MainFramePage.dart';

/// This is the first functions which is called in the app...
Future main() async {
  // Report all dart errors...
  try {
    runZoned<Future<void>>(launch, onError: (error, stackTrace) {
      if (!isInDebugMode) {
        bugs.reportError(error, stackTrace);
      } else {
        print(error);
        print(stackTrace);
      }
    });
  } catch (e) {
    print('Error: $e');
  }
}

/// Returns if the app is running in debug mode
bool get isInDebugMode {
  // Assume you're in production mode
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true, 'Is in debug mode');

  return inDebugMode;
}

/// Launches the app witch error catches and the correct theme
Future launch() async {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  // Start the app...
  runApp(MaterialApp(
    title: 'VsaApp',
    // Set font family and main colors...
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF64A441),
      accentColor: Color(0xFF5BC638),
      fontFamily: 'Ubuntu',
    ),
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    // Our app only supports the german language...
    supportedLocales: const [
      Locale('de'),
    ],
    initialRoute: '/',
    // Define three shortcuts for pages: loading, home and login...
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => LoadingPage(),
      '/main': (BuildContext context) => MainFrame(),
      '/login': (BuildContext context) => LoginPage(),
      '/intro': (BuildContext context) => IntroPage(),
      //'/scan': (BuildContext context) => ScanPage()
    },
  ));
}
