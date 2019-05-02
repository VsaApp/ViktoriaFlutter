import 'dart:convert';
import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart';
import 'package:viktoriaflutter/Localizations.dart';
import 'package:viktoriaflutter/Notices/AddNoticeDialog/AddNoticeAddTranscriptDialogWidget.dart';
import 'package:viktoriaflutter/Notices/AddNoticeDialog/AddNoticeSelectTypeDialogWidget.dart';
import 'package:viktoriaflutter/Notices/AddNoticeDialog/AddNoticeSetInformationDialogWidget.dart';
import 'package:viktoriaflutter/Notices/NoticeWidget/NoticeWidget.dart';
import 'package:viktoriaflutter/Notices/NoticesModel.dart';
import 'package:viktoriaflutter/Notices/NoticesWidget.dart';

class NoticesView extends NoticesState {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          padding: EdgeInsets.all(10),
          children: Notices.notices.map((notice) {
            return Hero(
              tag: Notices.notices.indexOf(notice).toString(),
              child: GestureDetector(
                child: NoticeWidget(notice: notice),
                onLongPress: () async {
                  if (await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:
                              Text(AppLocalizations.of(context).deleteNotice),
                          actions: <Widget>[
                            FlatButton(
                              color: Theme.of(context).accentColor,
                              child: Text(AppLocalizations.of(context).no,
                                  style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            FlatButton(
                              color: Theme.of(context).accentColor,
                              child: Text(AppLocalizations.of(context).yes,
                                  style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      })) {
                    setState(() {
                      Notices.removeNotice(notice);
                    });
                  }
                },
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                          notice.title,
                        ),
                      ),
                      body: ListView(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        children: <Widget>[
                          Hero(
                            tag: Notices.notices.indexOf(notice).toString(),
                            child: NoticeWidget(
                              notice: notice,
                              showExtended: true,
                            ),
                          ),
                          Container(),
                        ],
                      ),
                    );
                  }));
                },
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Container(
            child: FloatingActionButton(
              onPressed: createNewNotice,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  void createNewNotice() async {
    final data = await showDialog(
      context: context,
      builder: (BuildContext context) => AddNoticeSelectTypeDialog(),
    );
    if (data == null) return;
    final information = await showDialog(
      context: context,
      builder: (BuildContext context) => AddNoticeSetInformationDialog(),
    );
    if (information == null) return;
    if (data['type'] == 'file') {
      final TextRecognizer textRecognizer =
          FirebaseVision.instance.textRecognizer();
      File file = File(data['path']);
      String extension = file.path.split('.').last;
      if (extension == 'jpg' || extension == 'png') {
        List<File> files = [];
        File compressedFile = await FlutterNativeImage.compressImage(
          file.path,
          quality: 50,
          percentage: 50,
        );
        final image = decodeImage(await compressedFile.readAsBytes());
        for (int i = 0; i < 4; i++) {
          print(i * 90);
          final im = copyRotate(image, i * 90);
          File rotated = File(
              (compressedFile.path.split('.')..removeLast()).join('.') +
                  '+' +
                  (i * 90).toString() +
                  '.' +
                  compressedFile.path.split('.').last);
          await rotated
              .writeAsBytes((extension == 'png' ? encodeJpg : encodeJpg)(im));
          files.add(rotated);
        }
        print('files: ' + files.map((file) => file.path).toList().join(', '));
        List<VisionText> texts = [];
        for (int i = 0; i < files.length; i++) {
          final FirebaseVisionImage visionImage =
              FirebaseVisionImage.fromFile(files[i]);
          texts.add(await textRecognizer.processImage(visionImage));
        }
        VisionText visionText = (texts
              ..sort((a, b) => a.text.length.compareTo(b.text.length)))
            .reversed
            .toList()[0];
        final replace = await showDialog(
          context: context,
          builder: (BuildContext context) => AddNoticeAddTranscriptDialog(
                visionText: visionText,
              ),
        );
        if (replace[0]) {
          data['transcript'] = replace[1];
        }
      } else {
        print('Unknown file extension: ' + extension);
      }
    }
    Notices.addNotice(Notice(
      title: information['title'],
      description: information['description'],
      image: data['type'] == 'file'
          ? base64Encode(await File(data['path']).readAsBytes())
          : null,
      transcript: data['type'] == 'file' ? data['transcript'] : null,
    ));
    setState(() {});
  }
}
