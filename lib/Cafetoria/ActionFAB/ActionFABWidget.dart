import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';

/// Floating action button to show the keyfob and login data
class ActionFab extends StatefulWidget {
  /// Login callback
  final Function() onLogin;

  /// Order menu callback
  final Function() onOrder;

  /// The keyfob saldo
  final double saldo;

  /// The current data loading state
  final bool loading;

  // ignore: public_member_api_docs
  const ActionFab({
    @required this.onLogin,
    @required this.onOrder,
    @required this.saldo,
    @required this.loading,
  });

  @override
  ActionFabState createState() => ActionFabState();
}

// ignore: public_member_api_docs
class ActionFabState extends State<ActionFab>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _translateButton;
  static const Curve _curve = Curves.easeOut;
  static const double _fabHeight = 46;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _buttonColor = ColorTween(
          begin: Theme.of(context).primaryColor,
          end: Color(0xFF275600),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0,
            1,
            curve: Curves.linear,
          ),
        ));
        _translateButton = Tween<double>(
          begin: _fabHeight,
          end: 0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0,
            0.75,
            curve: _curve,
          ),
        ));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Animates the floating action buttons up or down
  void _animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
  }

  /// Small order FAB
  Widget order() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'order',
        mini: true,
        onPressed: () {
          _animate();
          widget.onOrder();
        },
        child: Icon(Icons.payment, color: Colors.white),
      ),
    );
  }

  /// Small login FAB
  Widget login() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'login',
        mini: true,
        onPressed: () {
          _animate();
          widget.onLogin();
        },
        child: Icon(Icons.vpn_key, color: Colors.white),
      ),
    );
  }

  /// Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton.extended(
        heroTag: 'toggle',
        backgroundColor: _buttonColor.value,
        onPressed: _animate,
        icon: Icon(
          Icons.euro_symbol,
          color: Colors.white,
        ),
        label: widget.loading
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
            : Text(
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
    if (_translateButton == null) {
      return Container();
    }
    // List of floating action buttons
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(
              0,
              _translateButton.value * 2,
              0,
            ),
            child: order(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0,
              _translateButton.value * 1,
              0,
            ),
            child: login(),
          ),
          toggle(),
        ]);
  }
}
