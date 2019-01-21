import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Home/HomePage.dart';
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
    HomePageState.messageBoardUpdated = (String action, String type, String group) async {
      if (type == 'messageboard-post') {
        await Messageboard.postsChanged(group);
        if (mounted) setState(() => null);
      }
      else if (type == 'messageboard-group') {
        await Messageboard.groupsChanged(group);
        if (mounted) {
          setState(() => null);
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).updatedGroups,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
            backgroundColor: Colors.black87,
            textColor: Colors.white
          );
        }
      }
    };
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });

    super.initState();
  }

  @override
  void dispose(){
    HomePageState.messageBoardUpdated = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      checkOnline.then((online) {
        if (online != 1) {
          // Show offline information
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(online == -1 ? AppLocalizations.of(context).oldDataIsShown : AppLocalizations.of(context).serverIsOffline),
              action: SnackBarAction(
                label: AppLocalizations.of(context).ok,
                onPressed: () {},
              ),
            ),
          );
        }
      });
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
                if (Messageboard.loggedIn.where((group) => group.status == 'activated').length > 0){
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
                child: GroupsPage(groups: Messageboard.userGroupList)
              )
            ]
          ),
        ),
      ),
    );
  }
}

/// Shows the list of all visible groups
/// 
/// First the user sees the blocked groups (when he creates them before), then the user sees the waiting groups 
/// and at least all activated groups
/// 
/// TODO: Sort them to following / not following and newesst on top
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
      child: ListView.builder(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 70),
          shrinkWrap: true,
          itemCount: allGroups.length == 0 ? 1 : allGroups.length,
          itemBuilder: (context, index) {
            if (allGroups.length == 0 ) return Center(child: Text(AppLocalizations.of(context).noGroupsToShow));
            else {
            Group group = allGroups[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupPage(group: group)));
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
                                    if (online == 1) setState(() => Messageboard.setFollowGroup(group.name, follow: !Messageboard.following.map((group) => group.name).contains(group.name), notifications: Messageboard.notifications.map((group) => group.name).contains(group.name)));
                                    else {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: online == -1 ? Text(AppLocalizations.of(context).onlyOnline) : Text(AppLocalizations.of(context).failedToConnectToServer),
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
                              (Messageboard.following.contains(group)) ?
                              FlatButton(
                                child: (group.status == 'activated') ? (Icon((!Messageboard.notifications.contains(group)) ? Icons.notifications_off : Icons.notifications_active, color: Theme.of(context).accentColor)) : Text(group.status == 'waiting' ? AppLocalizations.of(context).groupWaiting : AppLocalizations.of(context).ok),
                                onPressed: () {
                                  if (group.status == 'activated') {
                                    checkOnline.then((online) {
                                      if (online == 1) setState(() => Messageboard.setFollowGroup(group.name, follow: Messageboard.following.map((group) => group.name).contains(group.name), notifications: !Messageboard.notifications.map((group) => group.name).contains(group.name)));
                                      else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text(online == -1 ? AppLocalizations.of(context).onlyOnline : AppLocalizations.of(context).failedToConnectToServer),
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
                              ) : Container(),
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
        }
      )
    );
  }
}

/// Shows the feed (All posts for the following groups sortet by data)
/// 
/// The list adds step by step the posts when scrlled to the end of it.
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

  get feedGroups {
    return Messageboard.following.where((group) => group.status == 'activated').toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = (Messageboard.feed.posts.length == 0) ?
        <Widget>[
          !isUpdating ?
          Center(
              child: (feedGroups.length == 0) ?
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
          <Widget>[]..addAll(posts.map((post) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostPage(post: post))),
              child: Hero(
                tag: 'hero-' + post.id, 
                child: PostCard(post: post)
              )
            );
          }).toList())..add(
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

/// Shows a card for one post
/// 
/// The card hast a title, text, username and time
class PostCard extends StatefulWidget {
  /// Sets the post for the card
  final Post post;

  /// If [shortVersion] is true, the max length of the text is set to 500 characters.
  /// (Default sets to true)
  final bool shortVersion;

  PostCard({Key key, this.post, this.shortVersion = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostCardView();
  }
}

class PostCardView extends State<PostCard> {

  @override
  Widget build(BuildContext context) {
    String text = widget.post.text;
    if (widget.shortVersion && text.length > 200) text = text.substring(0, 200) + '...';
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                title: Text(widget.post.title),
                subtitle: Text(text),
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

/// The GradeFab has the options to add a group and write a post
class GradeFab extends StatefulWidget {
  /// Is called when the add post button is pressed
  final Function() onAddGroup;

  /// Is called when the write post button is pressed
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

/// This is the Page for one group.
/// 
/// Only in this view the user can sign in to the group.
/// 
/// When the user is logged in, he has the options to edit/delete the group and write a post for it 
class GroupPage extends StatefulWidget {
  final Group group;

  GroupPage({this.group});

  @override
  GroupView createState() => GroupView();
}

class GroupView extends State<GroupPage> {
  ScrollController _scrollController;
  TextEditingController editingController;
  TextEditingController currentPasswordController;
  TextEditingController newPasswordController;
  TextEditingController repeatNewPasswordController;
  SharedPreferences sharedPreferences;
  Map<String, IconData> appBarIcons = {};
  Function() updatedListener;
  final _formKey = GlobalKey<FormState>();
  final _newPasswordFocus = FocusNode();
  final _repeatNewPasswordFocus = FocusNode();
  bool _credentialsCorrect = true;
  bool _passwordsAreEqual = true;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });

    updatedListener = () => setState(() => null);
    widget.group.updatedListeners.add(updatedListener);

    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    widget.group.updatedListeners.remove(updatedListener);
    super.dispose();
  }

  /// An App bar item was selected
  /// This is only possible if the user is logged in int the current group
  void _selectedItem(String action){
    if (action == AppLocalizations.of(context).addPost) writePost();
    else if (action == AppLocalizations.of(context).editGroupInfo) editGroupInfo();
    else if (action == AppLocalizations.of(context).editGroupPassword) editGroupPassword();
    else if (action == AppLocalizations.of(context).removeGroup) deleteGroup();
  }

  /// Check the login
  void checkEditPassword() async {
    String group = widget.group.name;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _passwordsAreEqual = newPasswordController.text == repeatNewPasswordController.text;
    String _password = sha256.convert(utf8.encode(currentPasswordController.text)).toString();
    _credentialsCorrect = await api.checkLogin(username: group, password: _password);
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String _newPassword = sha256.convert(utf8.encode(newPasswordController.text)).toString();
      widget.group.update(sharedPreferences, newPassword: _newPassword).then((updated) {
        if (!updated) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).errorEditGroup,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
            backgroundColor: Colors.black87,
            textColor: Colors.white
          );
          Navigator.of(context).pop();
        }
        else {
          Navigator.of(context).pop();
        }
      });
      sharedPreferences.setString(Keys.groupEditPassword(group), _newPassword);
      sharedPreferences.commit();
    } else {
      currentPasswordController.clear();
    }
  }

  /// Edit group password
  void editGroupPassword() {
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    repeatNewPasswordController = TextEditingController();
    // Show edit group info dialog...
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).editGroupPassword),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Pin input
                    TextFormField(
                      controller: currentPasswordController,
                      validator: (value) {
                        if (!_credentialsCorrect) {
                          return AppLocalizations.of(context)
                              .passwordNotCorrect;
                        }
                      },
                      decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).currentPassword),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_newPasswordFocus);
                      },
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: newPasswordController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)
                              .fieldCantBeEmpty;
                        }
                      },
                      decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).newPassword),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_repeatNewPasswordFocus);
                      },
                      obscureText: true,
                      focusNode: _newPasswordFocus,
                    ),
                    TextFormField(
                      controller: repeatNewPasswordController,
                      validator: (value) {
                        if (!_passwordsAreEqual) {
                          return AppLocalizations.of(context)
                              .passwordNotEqual;
                        }
                      },
                      decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).repeatNewPassword),
                      onFieldSubmitted: (value) {
                        checkEditPassword();
                      },
                      obscureText: true,
                      focusNode: _repeatNewPasswordFocus,
                    ),
                    // Login button
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            checkEditPassword();
                          },
                          child: Text(AppLocalizations.of(context).login),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            )
          ],
        );
      },
    );
  }


  /// Edit group info
  void editGroupInfo() {
    // Check group password...
    getCorrectPassword((String password) {
      editingController = TextEditingController();
      editingController.text = widget.group.info;
      // Show edit group info dialog...
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).editGroupInfo),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  controller: editingController,
                  maxLines: 10,
                  maxLength: 400,
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    if (editingController.text != widget.group.info) {
                      widget.group.update(sharedPreferences, newInfo: editingController.text).then((updated) {
                        if (!updated) {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context).errorEditGroup,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                            backgroundColor: Colors.black87,
                            textColor: Colors.white
                          );
                          Navigator.of(context).pop();
                        }
                        else {
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  },
                )
              )
            ],
          );
        },
      );
    });
  }

  /// Delete the current group
  void deleteGroup() {
    confirmDeleteGroup(() {
      // Check group password...
      getCorrectPassword((String password) {
        // Remove group...
        Messageboard.removeGroup(widget.group, password,
          onRemoved: () {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context).removedGroup.replaceAll('%s', widget.group.name),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                backgroundColor: Colors.black87,
                textColor: Colors.white
            );
            Navigator.of(context).pop();
          },
          onFailed: () => print("Failed to remove group!")
        );
      });
    });
  }

  /// Gets the correct group password
  void getCorrectPassword(Function(String password) finished) async {
    bool correctLogin = await api.checkLogin(username: widget.group.name, password: sharedPreferences.getString(Keys.groupEditPassword(widget.group.name)));
    if (!correctLogin) {
      showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context1) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).passwordChanged),
            children: <Widget>[
              LoginDialog(group: widget.group.name, onFinished: () {
                finished(sharedPreferences.getString(Keys.groupEditPassword(widget.group.name)));
              }),
            ],
          );
        },
      );
    }
    else finished(sharedPreferences.getString(Keys.groupEditPassword(widget.group.name)));
  }

  /// Asks user if he really wants to delete the group
  void confirmDeleteGroup(Function() onDeleteGroup){
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).removeGroup),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).confirmDeleteGroup)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).yes),
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteGroup();
              },
            ),
          ],
        );
      },
    );
  }

  /// Write a new post...
  void writePost(){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => WritePostPage(group: widget.group.name, onFinished: () {
      setState(() => null);
    })));
  }

  @override
  Widget build(BuildContext context) {
    appBarIcons = {
      AppLocalizations.of(context).addPost: Icons.add,
      AppLocalizations.of(context).editGroupInfo: Icons.edit,
      AppLocalizations.of(context).editGroupPassword: Icons.vpn_key,
      AppLocalizations.of(context).removeGroup: Icons.delete
    };

    Group group = widget.group;
    if (group.status == 'waiting') appBarIcons.remove(AppLocalizations.of(context).addPost);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(AppLocalizations.of(context).groupInfo), actions: <Widget>[
        Messageboard.loggedIn.map((group) => group.name).contains(group.name) && group.status != 'blocked' ?
          PopupMenuButton<String>(
            onSelected: _selectedItem,
            itemBuilder: (BuildContext context) {
              return appBarIcons.keys.map((String name) => PopupMenuItem<String>(
                value: name,
                child: Text(name),
              )).toList();
            },
          ) : Container(),
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
                        title: Text(group.name + (group.status != 'blocked' ? ' (${group.follower})' : AppLocalizations.of(context).blockedInfo), style: TextStyle(color: group.status != 'blocked' ? Colors.black : Colors.red)),
                        subtitle: Text(group.info)
                      ),
                      ButtonTheme.bar( // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: (group.status == 'activated') ? <Widget>[
                            FlatButton(
                              child: Text((!Messageboard.loggedIn.map((group) => group.name).contains(group.name)) ? AppLocalizations.of(context).login : AppLocalizations.of(context).logout),
                              onPressed: () {
                                if (!Messageboard.loggedIn.map((group) => group.name).contains(group.name)){
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
                              child: Text((!Messageboard.following.map((group) => group.name).contains(group.name)) ? AppLocalizations.of(context).follow : AppLocalizations.of(context).doNotFollow),
                              onPressed: () {
                                checkOnline.then((online) {
                                  if (online == 1) setState(() {
                                    Messageboard.setFollowGroup(group.name, follow: !Messageboard.following.map((group) => group.name).contains(group.name), notifications: Messageboard.notifications.map((group) => group.name).contains(group.name));
                                    if (Messageboard.following.map((group) => group.name).contains(group.name)) {
                                      group.follower++;
                                    } else {
                                      group.follower--;
                                    }
                                  });
                                  else {
                                    Scaffold.of(context1).showSnackBar(
                                      SnackBar(
                                        content: Text(online == -1 ? AppLocalizations.of(context).onlyOnline : AppLocalizations.of(context).failedToConnectToServer),
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
                            (Messageboard.following.map((group) => group.name).contains(group.name)) ?
                            FlatButton(
                              child: Icon((!Messageboard.notifications.map((group) => group.name).contains(group.name)) ? Icons.notifications_off : Icons.notifications_active, color: Theme.of(context).accentColor),
                              onPressed: () {
                                checkOnline.then((online) {
                                  if (online == 1) setState(() => Messageboard.setFollowGroup(group.name, follow: Messageboard.following.map((group) => group.name).contains(group.name), notifications: !Messageboard.notifications.map((group) => group.name).contains(group.name)));
                                  else {
                                    Scaffold.of(context1).showSnackBar(
                                      SnackBar(
                                        content: Text(online == -1 ? AppLocalizations.of(context).onlyOnline : AppLocalizations.of(context).failedToConnectToServer),
                                        action: SnackBarAction(
                                          label: AppLocalizations.of(context).ok,
                                          onPressed: () {},
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                            ) : Container(),
                          ] : [
                            FlatButton(
                              child: Text(group.status == 'waiting' ? AppLocalizations.of(context).groupWaiting : AppLocalizations.of(context).ok),
                              onPressed: () {
                                if (group.status == 'blocked') {
                                  setState(() {
                                    Messageboard.confirmBolckedGroup(group.name);
                                    Fluttertoast.showToast(
                                        msg: AppLocalizations.of(context).blockedAccepted,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                                        backgroundColor: Colors.black87,
                                        textColor: Colors.white
                                    );
                                    Navigator.pop(context);
                                  });
                                }
                              }
                            ) 
                          ],
                        ),
                      ),
                      group.status == 'activated' ? Padding(child: PostsList(group: group, scrollController: _scrollController), padding: EdgeInsets.only(bottom: 20)) : Container()
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

/// Is a list with all posts for one group.
/// 
/// The list won't load all posts on one time, it's only load the next 10 posts when the user scrolled to the end of the list 
/// until it loads all posts of the group.
class PostsList extends StatefulWidget {

  /// Sets the group of the shown posts
  final Group group;

  /// The [ScrollContainer] says when the user scrolled to the end of the list and the [PostsList] has to load the next posts
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
          <Widget>[]..addAll(posts.map((post) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostPage(post: post, group: widget.group.name))),
              child: Hero(
                tag: 'hero-' + post.id, 
                child: PostCard(post: post)
              )
            );
          }).toList())..add(
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

/// Shows the post on a new page with all the options a post has
/// 
/// If the user is logged in in the group, then there are three options.
/// The user can visist the group page, edit the post and delete it.
/// 
/// But if the user is not logged in, then he only can visit the group page.
/// 
/// In Addition only in this view the user can see the whole message if the message is longer than 500 characters.
class PostPage extends StatefulWidget {
  final Post post;

  /// When the post page is called by the group page, then the group is set because the posts hasen an own group
  final String group;

  PostPage({this.post, this.group});

  @override
  PostView createState() => PostView();
}

class PostView extends State<PostPage> {
  ScrollController _scrollController;
  TextEditingController editTitleController = TextEditingController();
  TextEditingController editTextController = TextEditingController();
  final _textFocus = FocusNode();
  SharedPreferences sharedPreferences;
  Map<String, IconData> appBarIcons = {};
  Function() updatedListener;
  final _formKey = GlobalKey<FormState>();
  String username;
  String password;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    username = widget.post.username == '' ? widget.group : widget.post.username;
    updatedListener = () => setState(() => null);
    widget.post.updatedListeners.add(updatedListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.post.updatedListeners.remove(updatedListener);
    super.dispose();
  }

  /// An App bar item was selected
  /// This is only possible if the user is logged in int the current group
  void _selectedItem(String action){
    if (action == AppLocalizations.of(context).group) openGroup();
    else if (action == AppLocalizations.of(context).edit) editPost();
    else if (action == AppLocalizations.of(context).deletePost) deletePost();
  }

  /// Checks if the new title and text of the post is not empty and then it update the post on the api
  void checkEditForm() async {
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String title = editTitleController.text;
      String text = editTextController.text;
      Navigator.pop(context);
      widget.post.update(password, title, text,
        username: username,
        onUpdated: () {
          setState(() => null);
        },
        onFailed: () => print("Error edit post!")
      );
    }
  }

  /// Edit post title and text
  void editPost() {
    // Check group password...
    getCorrectPassword((String password) {
      this.password = password;
      editTitleController.text = widget.post.title;
      editTextController.text = widget.post.text;
      // Show edit group info dialog...
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).edit),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: editTitleController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context).fieldCantBeEmpty;
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
                        controller: editTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context).postText;
                          }
                        },
                        decoration: InputDecoration(hintText: AppLocalizations.of(context).postText),
                        onFieldSubmitted: (value) {
                          checkEditForm();
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
                              checkEditForm();
                            },
                            child: Text(AppLocalizations.of(context).ok)
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          );
        },
      );
    });
  }

  /// Deletes the current group
  void deletePost() {
    confirmDeletePost(() {
      // Check group password...
      getCorrectPassword((String password) {
        // Remove group...
        widget.post.delete(password, username: username,
          onDeleted: () {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context).removedPost,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                backgroundColor: Colors.black87,
                textColor: Colors.white
            );
            Navigator.of(context).pop();
          },
          onFailed: () => print("Failed to delete post!")
        );
      });
    });
  }

  /// Gets the correct group password
  void getCorrectPassword(Function(String password) finished) async {
    bool correctLogin = await api.checkLogin(username: username, password: sharedPreferences.getString(Keys.groupEditPassword(username)));
    if (!correctLogin) {
      showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context1) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).passwordChanged),
            children: <Widget>[
              LoginDialog(group: username, onFinished: () {
                finished(sharedPreferences.getString(Keys.groupEditPassword(username)));
              }),
            ],
          );
        },
      );
    }
    else finished(sharedPreferences.getString(Keys.groupEditPassword(username)));
  }

  /// Asks user if he really wants to delete the group
  void confirmDeletePost(Function() onDeletePost){
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deletePost),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).confirmDeletePost)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).yes),
              onPressed: () {
                Navigator.of(context).pop();
                onDeletePost();
              },
            ),
          ],
        );
      },
    );
  }

  /// Write a new post...
  void openGroup(){
    if (widget.group != null) Navigator.of(context).pop();
    else Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      GroupPage(group: Messageboard.allGroups.where((group) => group.name == username).toList()[0]);
    }));
  }

  @override
  Widget build(BuildContext context) {
    appBarIcons = {
      AppLocalizations.of(context).group: Icons.group,
      AppLocalizations.of(context).edit: Icons.edit,
      AppLocalizations.of(context).deletePost: Icons.delete
    };

    Post post = widget.post;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(username), actions: <Widget>[
        Messageboard.loggedIn.map((group) => group.name).contains(username) ?
          PopupMenuButton<String>(
            onSelected: _selectedItem,
            itemBuilder: (BuildContext context) {
              return appBarIcons.keys.map((String name) => PopupMenuItem<String>(
                value: name,
                child: Text(name),
              )).toList();
            },
          ) : IconButton(
            icon: Icon(Icons.group),
            tooltip: 'Group',
            onPressed: openGroup
          )
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
                tag: 'hero-' + post.id,
                child: PostCard(post: post, shortVersion: false)
              ),
            ),
          ]
        )
      ),
    );  
  }
}


/// The user can write a new post for one of the group where he is logged in.
/// 
/// In top of the page the user can select the group and below he can set the title and information text of the group.
class WritePostPage extends StatefulWidget {
  /// Is called when the post is created on the api and the feed is already updated
  final Function() onFinished;

  /// Only sets when the user creates a post for a specific group.
  /// This is used when a user clicked add post in the page of one group [GroupPage]
  /// 
  /// When the group is set the posts for this group will be reloaded, ohterwise only the feed will be reloaded.
  final String group;

  WritePostPage({this.onFinished, this.group});

  @override
  WritePostView createState() => WritePostView();
}

class WritePostView extends State<WritePostPage> {
  String _group = Messageboard.loggedIn[0].name;
  final _formKey = GlobalKey<FormState>();
  final _textFocus = FocusNode();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  int online = 1;
  bool showWidgets = false;
  bool addingError;

  /// Check the login
  void checkForm() async {
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      String username = _group;
      String title = _titleController.text;
      String text = _textController.text;
      Messageboard.addPost(username, title, text, updateGroup: widget.group != null,
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

    if (widget.group != null) _group = widget.group;

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
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.all(10.0),
            child: showWidgets? Column(
              children: <Widget>[
                (online != 1
                    ?
                    // Offline information
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(online == -1 ? AppLocalizations.of(context).goOnlineToLogin : AppLocalizations.of(context).failedToConnectToServer),
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
                            widget.group == null ?
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    items: Messageboard.loggedIn.where((group) => group.status == 'activated').map((Group group) {
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
                            ) : Container(),
                            TextFormField(
                              controller: _titleController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context).fieldCantBeEmpty;
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
                                  return AppLocalizations.of(context).fieldCantBeEmpty;
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
      ),
    );
  }
}

/// Page for create a new group.
/// 
/// The user gets a information with the adding group structure (E-Mail, etc.) and has to set the title and information of the group.
class AddGroupPage extends StatefulWidget {

  /// Is called when the group is created and the feed is updated
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
  int online = 1;
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
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.all(10.0),
            child: showWidgets? Column(
              children: <Widget>[
                Center(child: Text(AppLocalizations.of(context).addGroupInfo)),
                (online != 1
                    ?
                    // Offline information
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(online == -1 ? AppLocalizations.of(context).goOnlineToLogin : AppLocalizations.of(context).failedToConnectToServer),
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
      ),
    );
  }
}

/// Shows a dialog where the user has to set the password of a group
class LoginDialog extends StatefulWidget {
  /// Called when the correct password is set
  final Function onFinished;

  /// Sets the group
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
  int online = 1;

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
          (online != 1
              ?
              // Offline information
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(online == -1 ? AppLocalizations.of(context).goOnlineToLogin : AppLocalizations.of(context).failedToConnectToServer),
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
