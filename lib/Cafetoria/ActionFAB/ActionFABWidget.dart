import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Localizations.dart';

class ActionFab extends StatefulWidget {
  final Function() onLogin;
  final Function() onOrder;
  final double saldo;

  ActionFab({this.onLogin, this.onOrder, this.saldo});

  @override
  ActionFabState createState() => ActionFabState();
}

class ActionFabState extends State<ActionFab>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  bool isOpened = false;
  AnimationController animationController;
  Animation<Color> buttonColor;
  Animation<double> translateButton;
  Curve curve = Curves.easeOut;
  double fabHeight = 46.0;
  String grade;

  @override
  initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      buttonColor = ColorTween(
        begin: Theme.of(context).primaryColor,
        end: Color(0xFF275600),
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(
          0.00,
          1.00,
          curve: Curves.linear,
        ),
      ));
      translateButton = Tween<double>(
        begin: fabHeight,
        end: 0,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(
          0.0,
          0.75,
          curve: curve,
        ),
      ));
    });
    super.initState();
  }

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      animationController.forward();
    } else {
      animationController.reverse();
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
        backgroundColor: buttonColor.value,
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
              translateButton.value * 2,
              0.0,
            ),
            child: order(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              translateButton.value * 1,
              0.0,
            ),
            child: login(),
          ),
          toggle(),
        ]);
  }
}

