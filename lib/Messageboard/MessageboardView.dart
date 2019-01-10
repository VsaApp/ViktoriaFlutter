import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Network.dart';
import '../Keys.dart';
import '../Localizations.dart';
import 'MessageboardData.dart' as api;
import 'MessageboardModel.dart';

class MessageboardPage extends StatefulWidget {
  @override
  MessageboardView createState() => MessageboardView();
}

class MessageboardView extends State<MessageboardPage> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[MessageboardViews()],
        ),
        // FAB
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Container(
            child: GradeFab(
              onAddGroup: () {
                List<String> waitingGroups = (sharedPreferences.getStringList(Keys.waitingGroups) ?? []).toList();
                if (waitingGroups.length < 3){
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddGroupPage(onFinished: () {
                    setState(() => null);
                  })));
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).max3Groups,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                    backgroundColor: Colors.black87,
                    textColor: Colors.white
                  );
                }
              },
              onWritePost: () {
                if (Messageboard.loggedIn.length > 0){
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => WritePostPage(onFinished: () {
                    setState(() => null);
                  })));
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).noLoggedInGroup,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                    backgroundColor: Colors.black87,
                    textColor: Colors.white
                  );
                }
              },
            )
          ),
        ),
      ]),
    );
  }
}

class MessageboardViews extends StatefulWidget {

  MessageboardViews({Key key}) : super(key: key);

  @override
  MessageboardViewsState createState() => MessageboardViewsState();
}

class MessageboardViewsState extends State<MessageboardViews>
    with SingleTickerProviderStateMixin {

  SharedPreferences sharedPreferences;
  TabController _tabController;
  int pagesCount = 2;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    // Select the correct tab
    _tabController = TabController(vsync: this, length: pagesCount);
    _tabController.animateTo(Messageboard.feed.posts.length > 0 ? 0 : 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [AppLocalizations.of(context).feed, AppLocalizations.of(context).groups];
    if (sharedPreferences == null) {
      return Container();
    }
    return DefaultTabController(
      length: pagesCount,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: tabs.map((name) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(name),
              );
            }).toList(),
          ),
          // Tab bar views
          body: TabBarView(
            controller: _tabController,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: FeedPage()
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: GroupsPage(groups: Messageboard.publicGroups)
              )
            ]
          ),
        ),
      ),
    );
  }
}

class GroupsPage extends StatefulWidget {
  final List<Group> groups;

  GroupsPage({Key key, this.groups})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GroupsView();
  }
}

class GroupsView extends State<GroupsPage> {

  @override
  Widget build(BuildContext context) {
    List<Group> allGroups = Messageboard.myBlockedGroups..addAll(Messageboard.waiting)..addAll(widget.groups);
    return Container(
      child: allGroups.length == 0 ?
        Center(child: Text(AppLocalizations.of(context).noGroupsToShow)) :
        ListView.builder(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 70),
          shrinkWrap: true,
          itemCount: allGroups.length,
          itemBuilder: (context, index) {
            Group group = allGroups[index];
            return GestureDetector(
              onTap: () {
                if (group.status == 'activated') Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupPage(group: group)));
              },
              child: Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Hero(
                  tag: 'hero-' + group.name,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(group.name + (group.status != 'blocked' ? '' : AppLocalizations.of(context).blockedInfo), style: TextStyle(color: group.status != 'blocked' ? Colors.black : Colors.red)),
                          subtitle: Text(group.info)
                        ),
                        ButtonTheme.bar( // make buttons use the appropriate styles for cards
                          child: ButtonBar(
                            children: <Widget>[
                              (group.status == 'activated') ?
                              FlatButton(
                                child: Text((!Messageboard.following.contains(group)) ? AppLocalizations.of(context).follow : AppLocalizations.of(context).doNotFollow),
                                onPressed: () {
                                  checkOnline.then((online) {
                                    if (online) setState(() => Messageboard.toggleFollowingGroup(group.name));
                                    else {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text(AppLocalizations.of(context).onlyOnline),
                                          action: SnackBarAction(
                                            label: AppLocalizations.of(context).ok,
                                            onPressed: () {},
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                }
                              ) : Container(),
                              FlatButton(
                                child: (group.status == 'activated') ? (Icon((!Messageboard.notifications.contains(group)) ? Icons.notifications_off : Icons.notifications_active, color: Theme.of(context).accentColor)) : Text(group.status == 'waiting' ? AppLocalizations.of(context).groupWaiting : AppLocalizations.of(context).ok),
                                onPressed: () {
                                  if (group.status == 'activated') {
                                    checkOnline.then((online) {
                                      if (online) setState(() => Messageboard.toggleNotificationGroup(group.name));
                                      else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text(AppLocalizations.of(context).onlyOnline),
                                            action: SnackBarAction(
                                              label: AppLocalizations.of(context).ok,
                                              onPressed: () {},
                                            ),
                                          ),
                                        );
                                      }
                                    });
                                  }  else if (group.status == 'blocked') {
                                    setState(() => Messageboard.confirmBolckedGroup(group.name));
                                  }
                                }
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      )
    );
  }
}

class FeedPage extends StatefulWidget {
  FeedPage({Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FeedView();
  }
}

class FeedView extends State<FeedPage> {
  ScrollController _scrollController;
  SharedPreferences sharedPreferences;
  List<Post> posts = Messageboard.feed.posts;
  bool isUpdating = false;
  bool isAdding = false;
  bool active = true;

  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    // Select the correct tab
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        loadNewPosts();
      }
    });

    isUpdating = Messageboard.status == 'updating';

    Messageboard.statusListener = (String status) {
      if (status == 'updating') setState(() => isUpdating = true);
      else if (status == 'updated') setState(() {
        isUpdating = false;
        _scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        posts = Messageboard.feed.posts;
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).feedUpdated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
          backgroundColor: Colors.black87,
          textColor: Colors.white
        );
      });
    };

    super.initState();
  }

  void loadNewPosts(){
    if (!Messageboard.feed.loadComplete && !isAdding) {
      setState(() => isAdding = true);
      Messageboard.feed.loadNew().then((_) {
        setState(() {
          posts = Messageboard.feed.posts;
          isAdding = false;
        });
      });
    }
  }

  @override void dispose() {
      Messageboard.statusListener = null;
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = (Messageboard.feed.posts.length == 0) ?
        <Widget>[
          !isUpdating ?
          Center(
              child: (Messageboard.following.length == 0) ?
                Text(AppLocalizations.of(context).noGroups) :
                Text(AppLocalizations.of(context).noPosts)
          ) :
          Center(
            child: SizedBox(
                child: CircularProgressIndicator(strokeWidth: 2.0),
                height: 20.0,
                width: 20.0,
              )
          ),
        ]
        :
        (
          <Widget>[]..addAll(posts.map((post) => PostCard(post: post)).toList())..add(
          Center(
            child: (!Messageboard.feed.loadComplete) ?
            ( !isAdding ? 
              FlatButton(child: Icon(Icons.update, color: Theme.of(context).accentColor), onPressed: loadNewPosts) : 
              SizedBox(
                child: (isAdding) ? CircularProgressIndicator(strokeWidth: 2.0) : FlatButton(child: Icon(Icons.update, color: Theme.of(context).accentColor), onPressed: loadNewPosts),
                height: 20.0,
                width: 20.0,
              )
            )
                :
              Text(AppLocalizations.of(context).noPostsAnymore),
          ),
        )..insert(0, 
          Center(
            child: (isUpdating) ?
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 2.0),
                height: 20.0,
                width: 20.0,
              ) :
              Container(),
          ),
        )
      );
    return Container(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 70),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      )
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  PostCard({Key key, this.post})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostCardView();
  }
}

class PostCardView extends State<PostCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                title: Text(widget.post.title),
                subtitle: Text(widget.post.text),
              ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 10, bottom: 3),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            width: constraints.maxWidth * 0.60,
                            child: Text(widget.post.username, style: TextStyle(fontSize: 14, color: Theme.of(context).accentColor)),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            width: constraints.maxWidth * 0.40,
                            child: Text(widget.post.dateString, style: TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.end),
                          )
                        ],
                      ),
                    ]
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradeFab extends StatefulWidget {
  final Function() onAddGroup;
  final Function() onWritePost;

  GradeFab({this.onAddGroup, this.onWritePost});

  @override
  _GradeFabState createState() => _GradeFabState();
}

class _GradeFabState extends State<GradeFab>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 50.0;

  @override
  initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _buttonColor = ColorTween(
          begin: Theme.of(context).primaryColor,
          end: Color(0xff275600),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.00,
            1.00,
            curve: Curves.linear,
          ),
        ));
        _translateButton = Tween<double>(
          begin: _fabHeight,
          end: 0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.75,
            curve: _curve,
          ),
        ));
      });
    });
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  // Smaller add group FAB
  Widget addGroup() {
    return Container(
      child: Hero(
        tag: 'hero-addGroupPage',
        child: FloatingActionButton(
          heroTag: 'addGroup',
          mini: true,
          onPressed: () {
            animate();
            widget.onAddGroup();
          },
          tooltip: 'add group',
          child: Icon(Icons.group_add, color: Colors.white),
        ),
      ),
    );
  }

  // Smaller write post FAB
  Widget writePost() {
    return Container(
      child: Hero(
        tag: 'hero-addPost',
        child: FloatingActionButton(
          heroTag: 'writePost',
          mini: true,
          onPressed: () {
            animate();
            widget.onWritePost();
          },
          tooltip: 'write post',
          child: Icon(Icons.create, color: Colors.white),
        ),
      ),
    );
  }

  // Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'main',
        backgroundColor: _buttonColor.value,
        onPressed: () => animate(),
        tooltip: 'Grade',
        child: Icon(Icons.add, color: Colors.white)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null ||
        _translateButton == null ||
        _buttonColor == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2,
            0.0,
          ),
          child: addGroup(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: writePost(),
        ),
        toggle(),
      ]
    );
  }
}


class GroupPage extends StatefulWidget {
  final Group group;

  GroupPage({this.group});

  @override
  GroupView createState() => GroupView();
}

class GroupView extends State<GroupPage> {
  ScrollController _scrollController;
  TextEditingController editingController;
  SharedPreferences sharedPreferences;
  Group group;
  bool editMode = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    _scrollController = ScrollController();
    editingController = TextEditingController();
    editingController.text = widget.group.info;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Group group = widget.group;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(AppLocalizations.of(context).groupInfo), actions: <Widget>[
          editMode ? 
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => editMode = !editMode),
            ) : Container(),
          Messageboard.loggedIn.contains(group) ?
            IconButton(
              icon: Icon(!editMode ? Icons.edit : Icons.check, color: Colors.white),
              onPressed: () => setState(() {
                if (editMode) {
                  if (editingController.text != group.info) {
                    group.update(sharedPreferences, newInfo: editingController.text).then((updated) {
                      if (!updated) {
                        showDialog<String>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context1) {
                            return SimpleDialog(
                              title: Text(AppLocalizations.of(context)
                                  .passwordChanged),
                              children: <Widget>[
                                LoginDialog(group: group.name, onFinished: () => setState(() => group.update(sharedPreferences, newInfo: editingController.text))),
                              ],
                            );
                          },
                        );
                      }
                      else {
                        setState(() => null);
                      }
                    });
                  }
                }
                editMode = !editMode;
              } ),
            )
            :
            Container()
        ]
      ),
      body: Builder(
        builder: (BuildContext context1) => ListView(
          controller: _scrollController,
          shrinkWrap: true,
          children: <Widget>[ 
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.topLeft,
              child: Hero(
                tag: 'hero-' + group.name,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(group.name),
                        subtitle: editMode ? 
                          TextField(
                            controller: editingController,
                            maxLines: 10,
                            maxLength: 400,
                          ) : 
                          Text(group.info)
                      ),
                      ButtonTheme.bar( // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text((!Messageboard.loggedIn.contains(group)) ? AppLocalizations.of(context).login : AppLocalizations.of(context).logout),
                              onPressed: () {
                                if (!Messageboard.loggedIn.contains(group)){
                                  showDialog<String>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context1) {
                                      return SimpleDialog(
                                        title: Text(AppLocalizations.of(context)
                                            .login),
                                        children: <Widget>[
                                          LoginDialog(group: group.name, onFinished: () => setState(() => null)),
                                        ],
                                      );
                                    },
                                  );
                                }
                                else setState(() => Messageboard.toogleLoginGroup(group.name, login: false));
                              } 
                            ),
                            FlatButton(
                              child: Text((!Messageboard.following.contains(group)) ? AppLocalizations.of(context).follow : AppLocalizations.of(context).doNotFollow),
                              onPressed: () {
                                checkOnline.then((online) {
                                  if (online) setState(() => Messageboard.toggleFollowingGroup(group.name));
                                  else {
                                    Scaffold.of(context1).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context).onlyOnline),
                                        action: SnackBarAction(
                                          label: AppLocalizations.of(context).ok,
                                          onPressed: () {},
                                        ),
                                      ),
                                    );
                                  }
                                });
                              }
                            ),
                            FlatButton(
                              child: Icon((!Messageboard.notifications.contains(group)) ? Icons.notifications_off : Icons.notifications_active, color: Theme.of(context).accentColor),
                              onPressed: () {
                                checkOnline.then((online) {
                                  if (online) setState(() => Messageboard.toggleNotificationGroup(group.name));
                                  else {
                                    Scaffold.of(context1).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context).onlyOnline),
                                        action: SnackBarAction(
                                          label: AppLocalizations.of(context).ok,
                                          onPressed: () {},
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(child: PostsList(group: group, scrollController: _scrollController), padding: EdgeInsets.only(bottom: 20))
                    ],
                  ),
                ),
              ),
            ),
          ]
        )
      ),
    );  
  }
}

class PostsList extends StatefulWidget {
  final Group group;
  final ScrollController scrollController;

  PostsList({Key key, this.group, this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostsListView();
  }
}

class PostsListView extends State<PostsList> {
  ScrollController _scrollController;
  SharedPreferences sharedPreferences;
  List<Post> posts = [];
  bool show = false;
  Function() addedListener;

  void initState() {
    addedListener = () => setState(() {
      posts = widget.group.posts;
      widget.group.isAdding = false;
    });
    widget.group.addedListeners.add(addedListener);
    posts = widget.group.posts;
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });

    // Load the first posts...
    if (posts.length == 0) loadNewPosts();

    // Select the correct tab   
    _scrollController = widget.scrollController; 
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        loadNewPosts();
      }
    });

    // Start painting after the animation...
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (mounted) setState(() => show = true);
      else show = true;
    });

    super.initState();
  }

  void loadNewPosts(){
    if (!widget.group.loadComplete && !widget.group.isAdding) {
      if(mounted) setState(() => widget.group.isAdding = true);
      else widget.group.isAdding = true;
      widget.group.loadNew();
    }
  }

  @override
  void dispose(){
    widget.group.addedListeners.remove(addedListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || !show) return Center(
      child: SizedBox(
        child: CircularProgressIndicator(strokeWidth: 2.0),
        height: 20.0,
        width: 20.0,
      )
    );
    List<Widget> items = (widget.group.posts.length == 0 && !widget.group.isAdding) ?
        [
          Center(child: Text(AppLocalizations.of(context).noPostsInGroup)) 
        ]
        :
        (
          <Widget>[]..addAll(posts.map((post) => PostCard(post: post)).toList())..add(
          Center(
            child: (!widget.group.loadComplete) ?
            ( !widget.group.isAdding ? 
              FlatButton(child: Icon(Icons.update, color: Theme.of(context).accentColor), onPressed: loadNewPosts) : 
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 2.0),
                height: 20.0,
                width: 20.0,
              )
            )
                :
              Container(),
          ),
        )
      );
    return Container(
      child: Column(
        children: items,
      )
    );
  }
}

class WritePostPage extends StatefulWidget {
  final Function() onFinished;

  WritePostPage({this.onFinished});

  @override
  WritePostView createState() => WritePostView();
}

class WritePostView extends State<WritePostPage> {
  String _group = Messageboard.loggedIn[0].name;
  final _formKey = GlobalKey<FormState>();
  final _textFocus = FocusNode();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  bool online = true;
  bool showWidgets = false;
  bool addingError;

  /// Check the login
  void checkForm() async {
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String username = _group;
      String title = _titleController.text;
      String text = _textController.text;
      Messageboard.addPost(username, title, text,
        onAdded: () {
          widget.onFinished();
          Navigator.pop(context);
        },
        onFailed: () {
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context1) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context)
                    .passwordChanged),
                children: <Widget>[
                  LoginDialog(group: username, onFinished: () => setState(() => checkForm())),
                ],
              );
            },
          );
        }
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });

    Future.delayed(Duration(milliseconds: 100)).then((_) => setState(() => showWidgets = true));
  }

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).addPost)),
      body: Hero(
        tag: 'hero-addPost',
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(10.0),
          child: showWidgets? Column(
            children: <Widget>[
              (!online
                  ?
                  // Offline information
                  Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).goOnlineToLogin),
                            FlatButton(
                              color: Theme.of(context).accentColor,
                              child: Text(AppLocalizations.of(context).retry),
                              onPressed: () async {
                                // Retry
                                prepareLogin();
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  :
                  // Show form
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Center(child: Text(AppLocalizations.of(context).postGroup)),
                          // Group selector
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  items: Messageboard.loggedIn.map((Group group) {
                                    return DropdownMenuItem<String>(
                                      value: group.name,
                                      child: Text(group.name),
                                    );
                                  }).toList(),
                                  value: _group,
                                  onChanged: (group) {
                                    setState(() {
                                      _group = group;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _titleController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context).postTitle;
                              }
                            },
                            decoration: InputDecoration(hintText: AppLocalizations.of(context).postTitle),
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_textFocus);
                            },
                            autofocus: true,
                          ),
                          TextFormField(
                            maxLines: 10,
                            controller: _textController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context).postText;
                              }
                            },
                            decoration: InputDecoration(hintText: AppLocalizations.of(context).postText),
                            onFieldSubmitted: (value) {
                              checkForm();
                            },
                            focusNode: _textFocus,
                          ),
                          // Login button
                          Container(
                            margin: EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  checkForm();
                                },
                                child: Text(AppLocalizations.of(context).addPost)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
            ],
          ) : Container(),
        ),
      ),
    );
  }
}

class AddGroupPage extends StatefulWidget {
  final Function() onFinished;

  AddGroupPage({this.onFinished});

  @override
  AddGroupView createState() => AddGroupView();
}

class AddGroupView extends State<AddGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _infoFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameController = TextEditingController();
  final _infoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool online = true;
  bool showWidgets = false;
  bool addingError;

  /// Check the login
  void checkForm() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String _username = _usernameController.text;
      String _password = sha256.convert(utf8.encode(_passwordController.text)).toString();
      String _info = _infoController.text;
      Messageboard.addGroup(_username, _password, _info,
        onAdded: () {
          widget.onFinished();
        },
        onFailed: (int error) {
          if (error == -100) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).errorAddingGroup,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
              backgroundColor: Colors.black87,
              textColor: Colors.white
            );
          }
        }
      );
      Navigator.pop(context);
      
    } else {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });

    Future.delayed(Duration(milliseconds: 100)).then((_) => setState(() => showWidgets = true));
  }

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).addGroup)),
      body: Hero(
        tag: 'hero-addGroupPage',
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(10.0),
          child: showWidgets? Column(
            children: <Widget>[
              Center(child: Text(AppLocalizations.of(context).addGroupInfo)),
              (!online
                  ?
                  // Offline information
                  Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).goOnlineToLogin),
                            FlatButton(
                              color: Theme.of(context).accentColor,
                              child: Text(AppLocalizations.of(context).retry),
                              onPressed: () async {
                                // Retry
                                prepareLogin();
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  :
                  // Show form
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            maxLength: 25,
                            controller: _usernameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)
                                    .fieldCantBeEmpty;
                              }
                              if (value.contains('/')) {
                                return AppLocalizations.of(context)
                                    .noSlash;
                              }
                              if (Messageboard.allGroups.map((i) => i.name.toUpperCase()).toList().contains(value.toUpperCase())) {
                                return AppLocalizations.of(context).groupAlreadyExist;
                              }
                            },
                            decoration: InputDecoration(hintText: AppLocalizations.of(context).groupName),
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                          .requestFocus(_passwordFocus);
                            },
                            autofocus: true,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)
                                    .fieldCantBeEmpty;
                              }
                              if (value.contains('/')) {
                                return AppLocalizations.of(context)
                                    .noSlash;
                              }
                            },
                            decoration: InputDecoration(hintText: AppLocalizations.of(context).groupPassword),
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                          .requestFocus(_infoFocus);
                            },
                            obscureText: true,
                            focusNode: _passwordFocus,
                          ),

                          // Pin input
                          TextFormField(
                            maxLines: 10,
                            maxLength: 400,
                            controller: _infoController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)
                                    .fieldCantBeEmpty;
                              }
                              if (value.contains('/')) {
                                return AppLocalizations.of(context)
                                    .noSlash;
                              }
                            },
                            decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context).groupInfo),
                            onFieldSubmitted: (value) {
                              checkForm();
                            },
                            focusNode: _infoFocus,
                          ),
                          // Login button
                          Container(
                            margin: EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  checkForm();
                                },
                                child: Text(AppLocalizations.of(context).addGroup)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
            ],
          ) : Container(),
        ),
      ),
    );
  }
}



class LoginDialog extends StatefulWidget {
  final Function onFinished;
  final String group;
  LoginDialog({Key key, this.group, this.onFinished}) : super(key: key);
  @override
  LoginView createState() => LoginView();
}

class LoginView extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _focus = FocusNode();
  bool _credentialsCorrect = true;
  final _passwordController = TextEditingController();
  bool online = true;

  /// Check the login
  void checkForm() async {
    String group = widget.group;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _credentialsCorrect = await api.checkLogin(username: group, password: sha256.convert(utf8.encode(_passwordController.text)).toString());
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String _password = sha256.convert(utf8.encode(_passwordController.text)).toString();
      Messageboard.toogleLoginGroup(group, login: true);
      sharedPreferences.setString(Keys.groupEditPassword(group), _password);
      sharedPreferences.commit();
      Navigator.pop(context);
      // Update UI
      widget.onFinished();
    } else {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prepareLogin();
    });
  }

  void prepareLogin() {
    checkOnline.then((online) {
      setState(() {
        this.online = online;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          (!online
              ?
              // Offline information
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).goOnlineToLogin),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(AppLocalizations.of(context).retry),
                          onPressed: () async {
                            // Retry
                            prepareLogin();
                          },
                        )
                      ],
                    ),
                  ),
                )
              :
              // Show form
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Pin input
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)
                                .fieldCantBeEmpty;
                          }
                          if (!_credentialsCorrect) {
                            return AppLocalizations.of(context)
                                .passwordNotCorrect;
                          }
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).groupPassword),
                        onFieldSubmitted: (value) {
                          checkForm();
                        },
                        obscureText: true,
                        focusNode: _focus,
                      ),
                      // Login button
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              checkForm();
                            },
                            child: Text(AppLocalizations.of(context).login),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
        ],
      ),
    );
  }
}
