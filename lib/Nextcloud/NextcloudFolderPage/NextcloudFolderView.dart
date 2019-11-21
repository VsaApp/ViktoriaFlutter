import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../NextcloudFolderWidget/NextcloudFolderWidget.dart';
import 'NextcloudFolderPage.dart';

class NextcloudFolderPageView extends NextcloudFolderPageState {
  @override
  Widget build(BuildContext context) {
    List<Choice> choices = [
      Choice(Icons.folder, AppLocalizations.of(context).folder),
      Choice(MdiIcons.file, AppLocalizations.of(context).file),
    ];
    return directory.elements == null
        ? Center(
            child: SizedBox(
              child: CircularProgressIndicator(strokeWidth: 5.0),
              height: 50.0,
              width: 50.0,
            ),
          )
        : RefreshIndicator(
            onRefresh: onReload,
            child: ListView(
              padding: EdgeInsets.only(top: 10),
              children: directory.elements.map((element) {
                return NextcloudFolderWidget(
                    parent: this,
                    element: element,
                    onTap: () async {
                      if (element.isDirectory() && !element.loading && !directory.loading) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(element.name),
                                      actions: <Widget>[
                                        PopupMenuButton<int>(
                                          onSelected: (choice) async {
                                            if (choice == 0) {
                                              final name =
                                                  AppLocalizations.of(context)
                                                      .newDirectory;
                                              final path =
                                                  '${element.path}${Uri.encodeFull(name)}/';
                                              Directory dir = Directory(
                                                  name: name,
                                                  path: path,
                                                  modificationTime:
                                                      DateTime.now(),
                                                  isCreated: 2);
                                              (element as Directory)
                                                  .elements
                                                  .insert(0, dir);
                                              element.onUpdate(false);
                                            }
                                          },
                                          icon: Icon(Icons.add),
                                          itemBuilder: (context) => choices
                                              .map((choice) =>
                                                  PopupMenuItem<int>(
                                                    value:
                                                        choices.indexOf(choice),
                                                    enabled: choice.enabled,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          choice.icon,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        Container(
                                                          height: 1,
                                                          width: 10,
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        Text(
                                                          choice.label,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList()
                                              .cast<PopupMenuEntry<int>>()
                                              .toList(),
                                        )
                                      ],
                                    ),
                                    body: NextcloudFolderPage(
                                        directory: element))));
                      } else if (!element.loading && !directory.loading) {
                        await openFile(element);
                      }
                    });
              }).toList(),
            ));
  }
}
