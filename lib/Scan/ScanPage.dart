import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

import 'ScanView.dart';

class ScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanPageView();
  }
}

abstract class ScanPageState extends State<ScanPage> {
  int cameraOcr = FlutterMobileVision.CAMERA_BACK;
  Size previewOcr;
  List<OcrText> texts = [];
  bool scanCompleted = false;

  Future<Null> scan() async {
    List<OcrText> _texts = [];
    try {
      _texts = await FlutterMobileVision.read(
        flash: false,
        autoFocus: true,
        multiple: true,
        waitTap: true,
        showText: true,
        preview: previewOcr,
        camera: cameraOcr,
        fps: 2.0,
      );
    } on Exception {
      _texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() {
      texts = _texts;
      scanCompleted = true;
    });
  }

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((previewSizes) {
      setState(() {
        previewOcr = previewSizes[cameraOcr].first;
      });
      scan();
    });
  }
}
