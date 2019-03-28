import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'LoadingPage.dart';

class LoadingPageView extends LoadingPageState {
  @override
  Widget build(BuildContext context) {
    if (!loggedIn) return Container();
    double height = MediaQuery.of(context).size.height;
    List<Widget> items = texts.map((text) => Text(text)).toList();
    List<int> itemCharacters = texts.map((text) => text.length).toList();
    itemCharacters.sort((a, b) => b.compareTo(a));
    if (animation == null) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          showLogo
              ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: height -
                      ((allDownloadsCount -
                          (allDownloadsCount > 0 ? 1 : 0)) *
                          16)
                          .toDouble() -
                      (centerWidgetDimensions + 25) -
                      height / 5),
              child: SizedBox(
                child: PivotTransition(
                  turns: animation,
                  alignment: FractionalOffset(0.815, 0.835),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                  ),
                ),
                height: centerWidgetDimensions,
                width: centerWidgetDimensions,
              ),
            ),
          )
              : Container(),
          itemCharacters.length > 0
              ? Align(
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
              : Container(),
        ],
      ),
    );
  }
}

class PivotTransition extends AnimatedWidget {
  PivotTransition({
    Key key,
    this.alignment: FractionalOffset.center,
    @required Animation<double> turns,
    this.child,
  }) : super(key: key, listenable: turns);

  Animation<double> get turns => listenable;

  final FractionalOffset alignment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double turnsValue = turns.value;
    final Matrix4 transform = Matrix4.rotationZ(turnsValue * pi * 2.0);
    return new Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}
