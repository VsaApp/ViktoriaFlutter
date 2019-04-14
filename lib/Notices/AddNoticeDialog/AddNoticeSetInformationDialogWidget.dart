import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Localizations.dart';

class AddNoticeSetInformationDialog extends StatefulWidget {
  AddNoticeSetInformationDialog({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddNoticeSetInformationView();
}

class AddNoticeSetInformationView extends State<AddNoticeSetInformationDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).addNotice),
      children: <Widget>[
        SimpleDialogOption(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context).fieldCantBeEmpty;
                    }
                  },
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).title),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(descriptionFocus);
                  },
                ),
                TextFormField(
                  focusNode: descriptionFocus,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 15,
                  controller: descriptionController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).description),
                  onFieldSubmitted: (value) {
                    if (formKey.currentState.validate()) {
                      Navigator.of(context).pop({
                        'title': titleController.text,
                        'description': value,
                      });
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            Navigator.of(context).pop({
                              'title': titleController.text,
                              'description': descriptionController.text,
                            });
                          }
                        },
                        child: Text(AppLocalizations.of(context).addNotice)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
