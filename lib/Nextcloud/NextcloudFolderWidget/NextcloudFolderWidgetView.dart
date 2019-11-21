import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'NextcloudFolderWidget.dart';

class NextcloudFolderWidgetView extends NextcloudFolderWidgetState {
  @override
  Widget build(BuildContext context) {
    if (widget.element.isCreated == 2) onEdit();

    List<Choice> choices = [
      Choice(Icons.share, AppLocalizations.of(context).share),
      Choice(Icons.edit, AppLocalizations.of(context).rename),
      Choice(Icons.file_download, AppLocalizations.of(context).download,
          enabled: !widget.element.isDirectory()),
      Choice(Icons.delete, AppLocalizations.of(context).delete),
    ];
    return GestureDetector(
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
                                  color: Theme.of(context).primaryColor,
                                  size: 50,
                                )
                              : SizedBox(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 5.0),
                                  height: 50.0,
                                  width: 50.0,
                                ),
                        ),
                        Expanded(
                          flex: 78,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: !edit && widget.element.isCreated != 2
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.element.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor),
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
                        if (choices != null && widget.element.isCreated != 2 && !widget.element.loading && !widget.parent.directory.loading)
                          PopupMenuButton<IconData>(
                            onSelected: (choice) async {
                              int icon = choice.codePoint;

                              if (icon == Icons.delete.codePoint) {
                                widget.parent.directory.elements
                                    .remove(widget.element);
                                widget.parent.setState(() {
                                  widget.parent.directory =
                                      widget.parent.directory;
                                });
                                Nextcloud.delete(widget.element);
                              } else if (icon ==
                                  Icons.file_download.codePoint) {
                                if (!widget.element.isDirectory()) {
                                  setState(() => isLoading = true);
                                  await widget.onTap();
                                  setState(() => isLoading = false);
                                } else {
                                  //TODO: Download directory
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
                        else if (widget.element.loading || widget.parent.directory.loading) 
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 1.0),
                          )
                      ],
                    ));
              },
            )),
        onTap: () async {
          setState(() => isLoading = true);
          await widget.onTap();
          setState(() => isLoading = false);
        });
  }
}
