import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:viktoriaflutter/Localizations.dart';

class AddNoticeSelectTypeDialog extends StatefulWidget {
  AddNoticeSelectTypeDialog({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddNoticeSelectTypeView();
}

class AddNoticeSelectTypeView extends State<AddNoticeSelectTypeDialog> {
  TextEditingController textController = TextEditingController();
  FocusNode focus = FocusNode();
  SpeechRecognition speechRecognition;
  bool showSpeech = false;
  bool speechRecognitionAvailable = false;
  bool speechRecognitionIsListening = false;
  String speechLocale;
  String speechText = '';

  @override
  void initState() {
    super.initState();
    initSpeechRecognition();
  }

  void initSpeechRecognition() {
    speechRecognition = SpeechRecognition();

    speechRecognition.setAvailabilityHandler(
          (result) =>
          setState(
                () => speechRecognitionAvailable = result,
          ),
    );
    speechRecognition.setRecognitionStartedHandler(
          () =>
          setState(
                () => speechRecognitionIsListening = true,
          ),
    );
    speechRecognition.setRecognitionResultHandler(
          (result) =>
          setState(
                () => speechText = result,
          ),
    );
    speechRecognition.setRecognitionCompleteHandler(
          () =>
          setState(
                () => speechRecognitionIsListening = false,
          ),
    );
    speechRecognition.setCurrentLocaleHandler(
          (locale) =>
          setState(
                () => speechLocale = locale,
          ),
    );
    speechRecognition.activate().then(
          (result) =>
          setState(
                () => speechRecognitionAvailable = result,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).addNotice),
      children: <Widget>[
        SimpleDialogOption(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: Icon(Icons.text_fields),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(AppLocalizations.of(context).text),
                ],
              ),
            ],
          ),
          onPressed: () async {
            Navigator.of(context).pop({
              'type': 'text',
            });
          },
        ),
        SimpleDialogOption(
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.image),
                margin: EdgeInsets.only(right: 10),
              ),
              Text(AppLocalizations.of(context).gallery),
            ],
          ),
          onPressed: () async {
            Navigator.of(context).pop({
              'type': 'file',
              'path': (await ImagePicker.pickImage(source: ImageSource.gallery))
                  .path,
            });
          },
        ),
        SimpleDialogOption(
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.camera_alt),
                margin: EdgeInsets.only(right: 10),
              ),
              Text(AppLocalizations.of(context).camera),
            ],
          ),
          onPressed: () async {
            Navigator.of(context).pop({
              'type': 'file',
              'path': (await ImagePicker.pickImage(source: ImageSource.camera))
                  .path,
            });
          },
        ),
        SimpleDialogOption(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: Icon(Icons.mic),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(AppLocalizations
                      .of(context)
                      .audio),
                ],
              ),
              showSpeech
                  ? Column(
                children: <Widget>[
                  Text(speechText),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          speechRecognitionIsListening
                              ? Icons.mic_off
                              : Icons.mic,
                        ),
                        onPressed: () async {
                          if (speechRecognitionAvailable) {
                            // TODO: Implement permission check
                            /*
                                  List<Permissions> permissions =
                                      await Permission.getPermissionsStatus([
                                    PermissionName.Microphone,
                                  ]);
                                  List<PermissionName> permissionNames =
                                      (await Permission.requestPermissions([
                                    PermissionName.Calendar,
                                    PermissionName.Camera
                                  ]))
                                          .cast<PermissionName>();
                                  */
                            if (!speechRecognitionIsListening) {
                              speechRecognition
                                  .listen(locale: speechLocale)
                                  .then((result) => print(result));
                            } else {
                              speechRecognition
                                  .stop()
                                  .then((result) => print(result));
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          speechRecognition.cancel().then(
                                (result) =>
                                setState(
                                      () =>
                                  speechRecognitionIsListening =
                                      result,
                                ),
                          );
                          setState(() {
                            speechText = '';
                            showSpeech = false;
                          });
                        },
                      ),
                    ],
                  )
                ],
              )
                  : Container(),
            ],
          ),
          onPressed: () async {
            setState(() {
              showSpeech = !showSpeech;
            });
          },
        ),
      ],
    );
  }
}
