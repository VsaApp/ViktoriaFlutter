import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Widgets/EmptyList.dart';

/// A grouped sliver list with headers
class GroupList extends StatelessWidget {
  /// All groups
  final List<Group> groups;

  // ignore: public_member_api_docs
  const GroupList({@required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Container();
    }
    return CustomScrollView(
      slivers: groups
          .map(_getSectionWidgets)
          .toList()
          .reduce((i1, i2) => [...i1, ...i2]),
    );
  }

  List<Widget> _getSectionWidgets(Group group) {
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(child: group.header),
      ),
      if (group.children.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.only(
              bottom: groups.indexOf(group) == groups.length - 1 ? 20 : 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(group.children),
          ),
        )
      else if (group.emptyInfo != null)
        EmptyList(information: group.emptyInfo)
    ];
  }
}

/// A single group for the GroupList
class Group {
  /// The header of the group
  final PreferredSizeWidget header;

  /// All children of this group
  final List<Widget> children;

  /// Information for empty children
  final String emptyInfo;

  // ignore: public_member_api_docs
  const Group({@required this.header, @required this.children, this.emptyInfo});
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.child,
  })  : minHeight = child.preferredSize.height,
        maxHeight = child.preferredSize.height;
  final double minHeight;
  final double maxHeight;
  final PreferredSizeWidget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => minHeight;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.only(bottom: 0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            boxShadow: overlapsContent
                ? const <BoxShadow>[
                    BoxShadow(
                        color: Color.fromARGB(255, 200, 200, 200),
                        blurRadius: 10,
                        offset: Offset(0, 10)),
                  ]
                : null,
          ),
          child: Container(
            color: Colors.white,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
