import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'NextcloudFolderWidget.dart';

// ignore: public_member_api_docs
class NextcloudFolderWidgetView extends NextcloudFolderWidgetState {
  @override
  Widget build(BuildContext context) {
    if (widget.element.isCreated == 2) {
      onEdit();
    }
    if (!widget.element.containsListener(listener)) {
      newListener();
    }

    final List<Choice> choices = [
      Choice(Icons.share, AppLocalizations.of(context).share, enabled: false),
      Choice(Icons.edit, AppLocalizations.of(context).rename),
      Choice(Icons.file_download, AppLocalizations.of(context).download,
          enabled: !widget.element.isDirectory()),
      Choice(Icons.delete, AppLocalizations.of(context).delete),
    ];
    return GestureDetector(
      onTap: () async {
        setState(() => isLoading = true);
        await widget.onTap();
        setState(() => isLoading = false);
      },
      child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 14,
                        child: !isLoading
                            ? Icon(
                                widget.element.isDirectory()
                                    ? Icons.folder
                                    : MdiIcons.file,
                                color: widget.element.isDeleted
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                size: 50,
                              )
                            : SizedBox(
                                height: 50,
                                width: 50,
                                child:
                                    CircularProgressIndicator(strokeWidth: 5),
                              ),
                      ),
                      Expanded(
                        flex: 78,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: !edit && widget.element.isCreated != 2
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.element.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: widget.element.isDeleted
                                              ? Colors.grey
                                              : Theme.of(context).primaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      timeago.format(
                                          widget.element.modificationTime
                                              .toLocal(),
                                          locale: AppLocalizations.of(context)
                                              .locale
                                              .languageCode),
                                      style: TextStyle(color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )
                                  ],
                                )
                              : EditableText(
                                  autofocus: true,
                                  controller: textEditingController,
                                  focusNode: textFocus,
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.black87),
                                  backgroundCursorColor: Colors.transparent,
                                ),
                        ),
                      ),
                      if (choices != null &&
                          widget.element.isCreated != 2 &&
                          !widget.element.loading &&
                          !widget.parentDir.loading)
                        PopupMenuButton<IconData>(
                          onSelected: (choice) async {
                            final int icon = choice.codePoint;

                            if (icon == Icons.delete.codePoint) {
                              Nextcloud.delete(
                                  widget.element, widget.parentDir);
                            } else if (icon == Icons.file_download.codePoint) {
                              if (!widget.element.isDirectory()) {
                                setState(() => isLoading = true);
                                await widget.onTap();
                                setState(() => isLoading = false);
                              }
                            } else if (icon == Icons.edit.codePoint) {
                              onEdit();
                            }
                          },
                          itemBuilder: (context) => choices
                              .map((choice) => PopupMenuItem<IconData>(
                                    value: choice.icon,
                                    enabled: choice.enabled,
                                    child: Row(
                                      children: [
                                        Icon(
                                          choice.icon,
                                          color: Colors.black,
                                        ),
                                        Container(
                                          height: 1,
                                          width: 10,
                                          color: Colors.transparent,
                                        ),
                                        Text(choice.label),
                                      ],
                                    ),
                                  ))
                              .toList()
                              .cast<PopupMenuEntry<IconData>>()
                              .toList(),
                        ),
                      if (widget.element.isCreated == 2)
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => textFocus.unfocus(),
                        )
                      else if (widget.element.loading ||
                          widget.parentDir.loading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 1),
                        )
                    ],
                  ));
            },
          )),
    );
  }
}
