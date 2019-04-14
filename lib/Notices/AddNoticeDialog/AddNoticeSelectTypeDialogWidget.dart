import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      ],
    );
  }
}
