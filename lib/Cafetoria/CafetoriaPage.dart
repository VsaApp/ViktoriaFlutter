import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CafetoriaView.dart';

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaPageView createState() => CafetoriaPageView();
}

abstract class CafetoriaPageState extends State<CafetoriaPage> {
  SharedPreferences sharedPreferences;
}
