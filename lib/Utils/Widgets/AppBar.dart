import 'package:flutter/material.dart';

/// An app bar which can be modified from everywhere
class GlobalAppBar {
  static String _title = '';
  static PreferredSizeWidget _bottom;
  static final List<void Function()> _updateListener = [];
  static final ValueKey _key = ValueKey('AppBar');

  /// Update the app bar title
  static void updateTitle(String title) {
    _title = title;
    _updateListener.forEach((i) => i());
  }

  /// Update the app bar bottom
  static void updateBottom(PreferredSizeWidget bottom) {
    _bottom = bottom;
    _updateListener.forEach((i) => i());
  }

  /// Add an update listener
  static void addListener(void Function() listener) {
    _updateListener.add(listener);
  }

  /// Remove an update listener
  static void removeListener(void Function() listener) {
    _updateListener.add(listener);
  }

  /// Returns the current app bar
  static AppBar get appBar {
    return AppBar(
      key: _key,
      backgroundColor: Colors.white,
      title: Text(_title,
          style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w100)),
      bottom: _bottom,
    );
  }
}
