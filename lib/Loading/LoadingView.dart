import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'LoadingPage.dart';

// ignore: public_member_api_docs
class LoadingPageView extends LoadingPageState {
  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return Container();
    }
    final double height = MediaQuery.of(context).size.height;
    final List<Widget> items = texts.map((text) => Text(text)).toList();
    final List<int> itemCharacters = texts.map((text) => text.length).toList()
      ..sort((a, b) => b.compareTo(a));
    if (animation == null) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: height -
                      ((allDownloadsCount - (allDownloadsCount > 0 ? 1 : 0)) *
                              16)
                          .toDouble() -
                      (centerWidgetDimensions + 25) -
                      height / 5),
              child: SizedBox(
                height: centerWidgetDimensions,
                width: centerWidgetDimensions,
                child: PivotTransition(
                  turns: animation,
                  alignment: FractionalOffset(0.815, 0.835),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                  ),
                ),
              ),
            ),
          ),
          if (itemCharacters.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: height -
                      ((allDownloadsCount - 1) * 16).toDouble() -
                      height / 5,
                ),
                child: SizedBox(
                  height: ((texts.length + 1) * 16).toDouble(),
                  width: (itemCharacters[0] * 7).toDouble(),
                  child: showTexts
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items,
                        )
                      : Container(),
                ),
              ),
            )
          else
            Container(),
        ],
      ),
    );
  }
}

/// Defines the ginko pivot transition
class PivotTransition extends AnimatedWidget {
  // ignore: public_member_api_docs
  const PivotTransition({
    @required Animation<double> turns,
    Key key,
    this.alignment = FractionalOffset.center,
    this.child,
  }) : super(key: key, listenable: turns);

  Animation<double> get _turns => listenable;

  /// The animation alignment
  final FractionalOffset alignment;

  /// The child of the transition
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double turnsValue = _turns.value;
    final Matrix4 transform = Matrix4.rotationZ(turnsValue * pi * 2.0);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}
