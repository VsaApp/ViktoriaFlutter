import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Color.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../data/Cafetoria.dart';
import '../models/Cafetoria.dart';

Function(String input) jsonDecode = json.decode;

class CafetoriaPage extends StatefulWidget {
  @override
  CafetoriaView createState() => CafetoriaView();
}

class CafetoriaView extends State<CafetoriaPage> {
  SharedPreferences sharedPreferences;
  Cafetoria data;

  @override
  void initState() {
    // Download data
    download().then((data) {
      setState(() {
        this.data = data;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          data == null
              ?
              // Show loader
              Scaffold(
                  body: Center(
                    child: SizedBox(
                      child: new CircularProgressIndicator(strokeWidth: 5.0),
                      height: 75.0,
                      width: 75.0,
                    ),
                  ),
                )
              : Column(children: <Widget>[CafetoriaDayList(days: data.days)]),
          data == null
              ?
              // And disable FAB while loading
              Container()
              : Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Container(
                    child: ActionFab(
                        onLogin: () {
                          showDialog<String>(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context1) {
                              return SimpleDialog(
                                title: Text(AppLocalizations.of(context)
                                    .cafetoriaLogin),
                                children: <Widget>[
                                  LoginDialog(onFinished: () {
                                    setState(() {
                                      this.data = null;
                                    });
                                    download().then((data) {
                                      setState(() {
                                        this.data = data;
                                      });
                                    });
                                  })
                                ],
                              );
                            },
                          );
                        },
                        onOrder: () {
                          launch('https://www.opc-asp.de/vs-aachen/');
                        },
                        saldo: (data == null) ? -1.0 : data.saldo),
                  ),
                ),
        ],
      ),
    );
  }

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

class CafetoriaDayList extends StatefulWidget {
  final List<CafetoriaDay> days;

  CafetoriaDayList({Key key, this.days}) : super(key: key);

  @override
  CafetoriaDayListState createState() => CafetoriaDayListState();
}

class CafetoriaDayListState extends State<CafetoriaDayList>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  TabController _tabController;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    // Select the current weekday (if weekend then the days is monday)
    _tabController = new TabController(vsync: this, length: widget.days.length);
    int weekday = DateTime.now().weekday - 1;
    if (weekday > 4) weekday = 0;
    _tabController.animateTo(weekday);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return DefaultTabController(
      length: widget.days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          // Tab bar header...
          appBar: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child:
                    Text(day.weekday.substring(0, 2)), // Show all weekday names
              );
            }).toList(),
          ),
          // Tab bar views...
          body: TabBarView(
            controller: _tabController,
            children: widget.days.map((day) {
              List<MenuRow> rows =
                  day.menues.map((menu) => MenuRow(menu: menu)).toList();
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                // List of menues for one day
                child: ListView(
                  shrinkWrap: true,
                  children: (rows.length > 0)
                      ?
                      // Show the menues
                      rows
                      :
                      // No menues for this day
                      <Widget>[
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(AppLocalizations.of(context)
                                  .cafetoriaNoMenues),
                            ),
                          ),
                        ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class MenuRow extends StatelessWidget {
  const MenuRow({Key key, this.menu}) : super(key: key);

  final CafetoriaMenu menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Menu name
                        Container(
                          width: constraints.maxWidth * 0.80,
                          child: Text(
                            (menu.name.length > 1)
                                ? menu.name[0].toUpperCase() +
                                    menu.name.substring(1)
                                : menu.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Menu time
                        (menu.time.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.80,
                                child: Text(
                                  menu.time,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ))
                            : Container(),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // Menu price
                        Container(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.03),
                          width: constraints.maxWidth * 0.17,
                          child: Text(
                            '${menu.price}€',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ActionFab extends StatefulWidget {
  final Function() onLogin;
  final Function() onOrder;
  final double saldo;

  ActionFab({this.onLogin, this.onOrder, this.saldo});

  @override
  _ActionFabState createState() => _ActionFabState();
}

class _ActionFabState extends State<ActionFab>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 46.0;
  String grade;

  @override
  initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _buttonColor = ColorTween(
        begin: Theme.of(context).primaryColor,
        end: getColorHexFromStr('#275600'),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.00,
          1.00,
          curve: Curves.linear,
        ),
      ));
      _translateButton = Tween<double>(
        begin: _fabHeight,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.75,
          curve: _curve,
        ),
      ));
    });
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  // Smaller order FAB
  Widget order() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'order',
        mini: true,
        onPressed: () {
          animate();
          widget.onOrder();
        },
        child: Icon(Icons.payment, color: Colors.white),
      ),
    );
  }

  // Smaller login FAB
  Widget login() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'login',
        mini: true,
        onPressed: () {
          animate();
          widget.onLogin();
        },
        child: Icon(Icons.vpn_key, color: Colors.white),
      ),
    );
  }

  // Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton.extended(
        heroTag: 'toggle',
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        icon: Icon(
          Icons.euro_symbol,
          color: Colors.white,
        ),
        label: Text(
          widget.saldo == -1.0
              ? AppLocalizations.of(context).login
              : widget.saldo.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) return Container();
    // List of FABs
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 2,
              0.0,
            ),
            child: order(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 1,
              0.0,
            ),
            child: login(),
          ),
          toggle(),
        ]);
  }
}

class LoginDialog extends StatefulWidget {
  final Function onFinished;
  LoginDialog({Key key, this.onFinished}) : super(key: key);
  @override
  LoginView createState() => LoginView();
}

class LoginView extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _focus = FocusNode();
  bool _credentialsCorrect = true;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool online = true;

  // Check the login
  void checkForm() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _credentialsCorrect = await checkLogin(
        id: _idController.text, password: _passwordController.text);
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      sharedPreferences.setString(Keys.cafetoriaId, _idController.text);
      sharedPreferences.setString(
          Keys.cafetoriaPassword, _passwordController.text);
      sharedPreferences.commit();
      Navigator.pop(context);
      // Update UI
      widget.onFinished();
    } else {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });
  }

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          (!online
              ?
              // Offline information
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).goOnlineToLogin),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(AppLocalizations.of(context).retry),
                          onPressed: () async {
                            // Retry
                            prepareLogin();
                          },
                        )
                      ],
                    ),
                  ),
                )
              :
              // Show form
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // ID input
                      TextFormField(
                        controller: _idController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)
                                .fieldCantBeEmpty;
                          }
                          if (!_credentialsCorrect) {
                            return AppLocalizations.of(context)
                                .credentialsNotCorrect;
                          }
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).cafetoriaId),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_focus);
                        },
                      ),
                      // Pin input
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)
                                .fieldCantBeEmpty;
                          }
                          if (!_credentialsCorrect) {
                            return AppLocalizations.of(context)
                                .credentialsNotCorrect;
                          }
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).cafetoriaPassword),
                        onFieldSubmitted: (value) {
                          checkForm();
                        },
                        obscureText: true,
                        focusNode: _focus,
                      ),
                      // Login button
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              checkForm();
                            },
                            child: Text(AppLocalizations.of(context).login),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
        ],
      ),
    );
  }
}
