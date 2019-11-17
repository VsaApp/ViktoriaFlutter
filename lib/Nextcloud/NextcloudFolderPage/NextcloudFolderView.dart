import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import '../NextcloudFolderWidget/NextcloudFolderWidget.dart';
import 'NextcloudFolderPage.dart';

class NextcloudFolderPageView extends NextcloudFolderPageState {

  @override
  Widget build(BuildContext context) {
    return directory.elements == null ? 
      Center(
        child: SizedBox(
          child: CircularProgressIndicator(strokeWidth: 5.0),
          height: 75.0,
          width: 75.0,
        ),
      ) :
      RefreshIndicator(
        onRefresh: onReload,
        child: ListView(
          padding: EdgeInsets.only(top: 10),
          children: directory.elements.map((element) {
            return NextcloudFolderWidget(element: element,
              onTap: () async {
                if (element.isDirectory()) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Scaffold(
                      appBar: AppBar(title: Text(element.name),),
                      body: NextcloudFolderPage(
                        name: element.name,
                        path: element.path,
                      )
                    ))
                  );
                } 
                else {
                  await openFile(element);
                }
              });
          }).toList(),
        )
      );
  }
}