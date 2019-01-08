import 'dart:io';
import 'package:flutter/material.dart';
import 'UnitPlanView.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

abstract class UnitPlanState extends State<UnitPlanPage> {
  bool offlineShown = false;

  Future<bool> get checkOnline async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
}
