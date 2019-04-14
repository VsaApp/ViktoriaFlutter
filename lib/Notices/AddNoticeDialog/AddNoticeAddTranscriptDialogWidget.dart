import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:viktoriaflutter/Localizations.dart';

class AddNoticeAddTranscriptDialog extends StatefulWidget {
  final VisionText visionText;

  AddNoticeAddTranscriptDialog({
    Key key,
    @required this.visionText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddNoticeAddTranscriptView();
}

class AddNoticeAddTranscriptView extends State<AddNoticeAddTranscriptDialog> {
  List<ItemData> items;

  int indexOfKey(Key key) {
    return items.indexWhere((ItemData d) => d.key == key);
  }

  bool reorderCallback(Key item, Key newPosition) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    final draggedItem = items[draggingIndex];
    setState(() {
      items.removeAt(draggingIndex);
      items.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  @override
  void initState() {
    List<String> texts = widget.visionText.blocks.reversed
        .toList()
        .map((block) => block.text)
        .toList();
    items = texts
        .map((text) => ItemData(text, ValueKey(texts.indexOf(text))))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.only(left: 10, right: 10),
      titlePadding: EdgeInsets.all(10),
      title: Text(
        AppLocalizations.of(context).textDetectedAddTranscript,
        style: TextStyle(fontSize: 16),
      ),
      content: ReorderableList(
        onReorder: this.reorderCallback,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Item(
                    data: items[index],
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                  );
                },
                childCount: items.length,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          color: Theme.of(context).accentColor,
          child: Text(AppLocalizations.of(context).no,
              style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop([false]);
          },
        ),
        FlatButton(
          color: Theme.of(context).accentColor,
          child: Text(AppLocalizations.of(context).yes,
              style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context)
                .pop([true, items.map((item) => item.text).join('\n')]);
          },
        ),
      ],
    );
  }
}

class Item extends StatelessWidget {
  Item({
    this.data,
    this.isFirst,
    this.isLast,
  });

  final ItemData data;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
        border: Border(
          top: !isFirst ? BorderSide(color: Colors.black54) : BorderSide.none,
          /*top: isFirst && !placeholder
              ? Divider.createBorderSide(context)
              : BorderSide.none,
          bottom: isLast && placeholder
              ? BorderSide.none
              : Divider.createBorderSide(context),*/
        ),
        color: placeholder ? null : Colors.white,
      );
    }

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Opacity(
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                    child: Text(data.text,
                        style: Theme.of(context).textTheme.subhead),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    content = DelayedReorderableListener(
      child: content,
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(key: data.key, childBuilder: _buildChild);
  }
}

class ItemData {
  ItemData(this.text, this.key);

  final String text;

  final Key key;
}
