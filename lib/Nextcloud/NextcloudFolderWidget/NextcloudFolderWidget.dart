import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart';
import '../NextcloudModel.dart' as cloud;
import 'NextcloudFolderWidgetView.dart';

/// A widget for an nextcloud folder or file
class NextcloudFolderWidget extends StatefulWidget {
  /// Parent directory
  final Directory parentDir;

  /// The element that should be shown
  final cloud.Element element;

  /// On tap listener
  final Function() onTap;

  // ignore: public_member_api_docs
  const NextcloudFolderWidget({this.parentDir, this.element, this.onTap});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderWidgetView();
  }
}

// ignore: public_member_api_docs
abstract class NextcloudFolderWidgetState extends State<NextcloudFolderWidget> {
  /// Editing controller for renaming the element
  TextEditingController textEditingController;

  /// Text focus for renaming the element
  FocusNode textFocus;

  /// Defines the current loading state
  bool isLoading = false;

  /// Defines the current edit state
  bool edit = false;

  /// Defines the element listener
  void Function() listener;

  @override
  void initState() {
    newListener();
    super.initState();
  }

  /// Sets a new listener for the current element
  void newListener() {
    listener = widget.element.addListener(() {
      if (mounted) {
        setState(() => null);
      }
    });
  }

  @override
  void dispose() {
    widget.element.removeListener(listener);
    super.dispose();
  }

  /// Start edit mode
  void onEdit() {
    setState(() {
      textEditingController = TextEditingController(text: widget.element.name);
      textFocus = FocusNode();
      edit = true;
    });
    textFocus.addListener(() {
      if (!textFocus.hasFocus && textEditingController.text.isNotEmpty) {
        setState(() {
          edit = false;
          if (widget.element.isCreated != 2) {
            Nextcloud.rename(widget.element, textEditingController.text);
          } else {
            final List<String> path = widget.element.path.split('/');
            path
              ..removeAt(path.length - 2)
              ..insert(path.length - 1, Uri.encodeFull(textEditingController.text));
            widget.element.path = path.join('/');
            widget.element.name = textEditingController.text;
            Nextcloud.mkDir(widget.element);
            setState(() {
              widget.element.isCreated = 1;
            });
          }
        });
      } else if (!textFocus.hasFocus) {
        setState(() {
          edit = false;
        });
      }
    });
  }
}
