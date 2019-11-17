import 'package:flutter/material.dart';
import 'NextcloudFolderWidget.dart';

class NextcloudFolderWidgetView extends NextcloudFolderWidgetState {
    @override
  Widget build(BuildContext context) {
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
                    child: !isLoading ? Icon(
                      widget.element.isDirectory() ? Icons.folder : Icons.text_fields,
                      color: Theme.of(context).primaryColor,
                      size: 50,
                    ) : SizedBox(
                      child: CircularProgressIndicator(strokeWidth: 5.0),
                      height: 50.0,
                      width: 50.0,
                    ),
                  ),
                  Expanded(
                    flex: 78,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.element.name, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.element.modificationTime.split(' ').sublist(1, 4).join(' '),
                            style: TextStyle(
                              color: Colors.black54
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      )
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () => null,
                    ),
                  )
                  
                ],
              )
            );
          },
        )
      ),
      onTap: () async {
        setState(() => isLoading = true); 
        await widget.onTap();
        setState(() => isLoading = false); 
      }
    );
  }
}