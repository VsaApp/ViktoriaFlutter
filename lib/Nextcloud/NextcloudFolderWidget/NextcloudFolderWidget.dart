import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudFolderPage/NextcloudFolderPage.dart';
import '../NextcloudModel.dart' as cloud;
import 'NextcloudFolderWidgetView.dart';

class NextcloudFolderWidget extends StatefulWidget {
  final NextcloudFolderPageState parent;
  final cloud.Element element;
  final Function() onTap;

  NextcloudFolderWidget({this.parent, this.element, this.onTap});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderWidgetView();
  }
}

abstract class NextcloudFolderWidgetState extends State<NextcloudFolderWidget> {
  TextEditingController textEditingController;
  FocusNode textFocus;
  bool isLoading = false;
  bool edit = false;
  void Function() listener;

  @override
  void initState() {
    newListener();
    super.initState();
  }

  void newListener() {
    listener = widget.element.addListener(() {
      if (mounted) setState(() => null);
    });
  }

  @override
  void dispose() {
    widget.element.removeListener(listener);
    super.dispose();
  }

  void onEdit() {
    setState(() {
      textEditingController = TextEditingController(text: widget.element.name);
      textFocus = FocusNode();
      edit = true;
    });
    textFocus.addListener(() {
      if (!textFocus.hasFocus && textEditingController.text.isNotEmpty)
        setState(() {
          edit = false;
          if (widget.element.isCreated != 2) {
            Nextcloud.rename(widget.element, textEditingController.text);
          } else {
            List<String> path = widget.element.path.split('/');
            path.removeAt(path.length - 2);
            path.add(Uri.encodeFull(textEditingController.text));
            widget.element.path = path.join('/');
            widget.element.name = textEditingController.text;
            Nextcloud.mkDir(widget.element);
            setState(() {
              widget.element.isCreated = 1;
            });
          }
        });
      else if (!textFocus.hasFocus) {
        setState(() {
          edit = false;
        });
      }
    });
  }
}
