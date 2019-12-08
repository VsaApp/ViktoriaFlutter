import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Home/HomeView.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Widgets/AppBar.dart';

/// The home page of the app
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageView();
}

// ignore: public_member_api_docs
abstract class HomePageState extends State<HomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
      GlobalAppBar.updateTitle(AppLocalizations.of(context).timetable);
      GlobalAppBar.updateBottom(null);
    });
    super.initState();
  }
}
