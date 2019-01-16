import 'dart:convert';

import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import 'MessageboardData.dart' as data;


/// Defines the messageboard...
class Messageboard {
  static SharedPreferences sharedPreferences;
  static List<Group> allGroups;
  static Feed feed;
  static Function(String status) statusListener;
  static String _status;
  static int currentUpdateProcesses = 0;

  static List<Group> get userGroupList {

    // Add al other public groups sorted by the follower count...
    List<Group> followingGroups = following;
    List<Group> loggedinGroups = loggedIn;
    List<Group> otherGroups = publicGroups;
    otherGroups.sort((Group group1, Group group2) {
      if (loggedinGroups.contains(group1) ^ loggedinGroups.contains(group2)) {
        return loggedinGroups.contains(group1) ? -1 : 1;
      }
      if (followingGroups.contains(group1) ^ followingGroups.contains(group2)) {
        return followingGroups.contains(group1) ? -1 : 1;
      }
      if (group1.follower == group2.follower) return 0;
      return (group1.follower > group2.follower) ? -1 : 1;
    });

    return otherGroups;
  }

  static List<Group> get publicGroups {
    return allGroups.where((group) => group.status == 'activated').toList();
  }

  static List<Group> get blockedGroups {
    return allGroups.where((group) => group.status == 'blocked').toList();
  }

  static List<Group> get myBlockedGroups {
    List<Group> blockedGroups = (sharedPreferences.getStringList(Keys.blockedGroups) ?? []).map((group) {
      List<Group> g = allGroups.where((i) => i.name == group).toList();

      // If the group exist, return the group...
      if (g.length == 1) return g[0];
      return null;
    }).toList().where((group) => group != null).toList();

    /// Delete all deleted groups in the preferences...
    return blockedGroups;
  }

  /// Set the loading status and call the listener...
  static set status(String status) {
    _status = status;
    if (statusListener != null) statusListener(status);
  }

  static get status {
    return _status;
  }

  /// Get all logged in groups...
  static List<Group> get loggedIn {
    List<String> deletedGroups = [];
    List<Group> groups = (sharedPreferences.getStringList(Keys.loggedInGroups) ?? []).map((group) {
      List<Group> g = allGroups.where((i) => i.name == group).toList();

      // If the group exist, return the group...
      if (g.length == 1) return g[0];
      else deletedGroups.add(group);
      return null;
    }).where((group) => group != null).toList();

    // Delete all deleted groups in the preferences...
    if (deletedGroups.length > 0) sharedPreferences.setStringList(Keys.loggedInGroups, groups.map((i) => i.name).toList());
    
    return groups;
  }

  /// Get all groups which the user follow...
  static List<Group> get following{
    List<String> deletedGroups = [];
    List<Group> following = (sharedPreferences.getStringList(Keys.feedGroups) ?? []).map((group) {
      List<Group> g = allGroups.where((i) => i.name == group).toList();

      // If the group exist, return the group...
      if (g.length == 1) return g[0];
      else deletedGroups.add(group);
      return null;
    }).toList().where((group) => group != null).toList();

    // Delete all deleted groups in the preferences...
    if (deletedGroups.length > 0) sharedPreferences.setStringList(Keys.feedGroups, following.map((i) => i.name).toList());
    
    return following;
  }

  /// Get all groups which the user get notifiations...
  static List<Group> get notifications{
    List<String> deletedGroups = [];
    List<Group> notifications = (sharedPreferences.getStringList(Keys.notificationGroups) ?? []).map((group) {
      List<Group> g = allGroups.where((i) => i.name == group).toList();

      // If the group exist, return the group...
      if (g.length == 1) return g[0];
      else deletedGroups.add(group);
      return null;
    }).toList().where((group) => group != null).toList();

    /// Delete all deleted groups in the preferences...
    if (deletedGroups.length > 0) sharedPreferences.setStringList(Keys.notificationGroups, notifications.map((i) => i.name).toList());
    
    return notifications;
  }

  /// Get all groups which the user get notifiations...
  static void syncTags() async {
    // First delete all unitPLan tags...
    Map<String, dynamic> allTags = await OneSignal.shared.getTags();
    List<String> allGroupKeys = allGroups.map((Group group) => Keys.messageboardGroupTag(group.name)).toList();
    allTags.keys.where((String tag) =>  !allGroupKeys.contains(tag)).forEach((String tag) {
      OneSignal.shared.deleteTag(tag);
    });
  }

  /// Get all groups which the user is waiting for a confirmation...
  static List<Group> get waiting {    
    List<Group> waitingGroups = (sharedPreferences.getStringList(Keys.waitingGroups) ?? []).map((group) {
      List<Group> g = allGroups.where((i) => i.name == group).toList();

      // If the group exist, return the group...
      if (g.length == 1) return g[0];
      return null;
    }).toList().where((group) => group != null).toList();

    /// Delete all deleted groups in the preferences...
    return waitingGroups;
  }

  /// Add a group to the waiting list...
  /// 
  /// onFailed is called when the adding process is failed. 
  /// Error -101 is when there already are three waiting groups and
  /// error -100 is when the api adding process failed
  static void addGroup(String username, String password, String info, {Function() onAdded, Function(int error) onFailed}) {    
    // Count the current waiting groups...
    List<String> currentList = (sharedPreferences.getStringList(Keys.waitingGroups) ?? []).toList();
    
    // If there are max 2 waiting groups, add this group...
    if (currentList.length < 3) {
      // Add the group in the preferences...
      sharedPreferences.setStringList(Keys.waitingGroups, currentList..add(username));
      // Add group to the api...
      data.addGroup(username: username, password: password, info: info).then((successfully) {
        if (successfully) {
          // Save login data for this group...
          toogleLoginGroup(username, login: true);
          sharedPreferences.setString(Keys.groupEditPassword(username), password);
          // Update groups list...
          data.downloadGroups().then((_) {
            setFollowGroup(username, follow: true, notifications: true);
            if (onAdded != null) onAdded();
          });
        }
        else if (onFailed != null) onFailed(-100);
      });
    }
    else {
      if (onFailed != null) onFailed(-101);
    }
  }

  /// Removes a group from the api and preferences...
  static void removeGroup(Group group, String password, {Function() onRemoved, Function() onFailed}) {    
    // Remove group in preferences...
    toogleLoginGroup(group.name, login: false);
    setFollowGroup(group.name, follow: false, notifications: false);
    if (group.status == 'waiting') {
      List<String> currentWaitingGroups = sharedPreferences.getStringList(Keys.waitingGroups) ?? [];
      if (currentWaitingGroups.contains(group.name)){
        sharedPreferences.setStringList(Keys.waitingGroups, currentWaitingGroups..remove(group.name));
      }
    }
    // Remve group from the api...
    data.removeGroup(username: group.name, password: password).then((successfully) {
      if (successfully) {
        // Remove login data for this group...
        sharedPreferences.remove(Keys.groupEditPassword(group.name));
        // Update groups list...
        data.downloadGroups().then((_) {
          feed.update().then((_){
            if (onRemoved != null) onRemoved();
          });
        });
      }
      else if (onFailed != null) onFailed();
    });
  }

  /// Add a Post to ta group...
  static void addPost(String username, String title, String text, {Function() onAdded, Function() onFailed, bool updateGroup = false}) {    
    // Add group to the api...
    data.addPost(username: username, password: sharedPreferences.getString(Keys.groupEditPassword(username)), title: title, text: text).then((successfully) async {
      if (successfully) {
        // Update feed...
        await feed.update();
        if (updateGroup) await allGroups.where((group) => group.name == username).toList()[0].reloadPosts();
        if (onAdded != null) onAdded();
      }
      else if (onFailed != null) onFailed();
    });    
  }

  /// Switchs a group from the waiting list to the activated list...
  static void confirmWaitingGroup(String username) {    
    List<String> currentList = (sharedPreferences.getStringList(Keys.waitingGroups) ?? []).toList();
    if (!currentList.contains(username)) throw 'confirmWaitingGroup: "$username" do not exist!';
    sharedPreferences.setStringList(Keys.waitingGroups, currentList..remove(currentList..remove(username)));
  }

  /// Switchs a group from the waiting list to the blocked list...
  static void blockWaitingGroup(String username) {    
    List<String> currentList = (sharedPreferences.getStringList(Keys.waitingGroups) ?? []).toList();
    if (!currentList.contains(username)) throw 'blockWaitingGroup: "$username" do not exist!';

    // Add this group to the blocked groups and remove it from the waiting groups...
    sharedPreferences.setStringList(Keys.blockedGroups, (sharedPreferences.getStringList(Keys.blockedGroups) ?? [])..add(username));
    sharedPreferences.setStringList(Keys.waitingGroups, currentList..remove(username));
  }

  /// Removes a group from the blocked list...
  static void confirmBolckedGroup(String username) {    
    List<String> currentList = (sharedPreferences.getStringList(Keys.blockedGroups) ?? []).toList();
    if (!currentList.contains(username)) throw 'confirmBolckedGroup: "$username" do not exist!';
    sharedPreferences.setStringList(Keys.blockedGroups, currentList..remove(username));
  }

  /// Sets the login state of a group
  /// 
  /// bool login sets the must value
  static void toogleLoginGroup(String username, {bool login}) {
    List<String> groups = (sharedPreferences.getStringList(Keys.loggedInGroups) ?? []);

    if (login != null){
      if (login && !groups.contains(username)) groups.add(username);
      else if (!login && groups.contains(username)) groups.remove(username);
    }
    else if (groups.contains(username)) groups.remove(username);
    else groups.add(username);

    // Save new groups list in the preferences...
    sharedPreferences.setStringList(Keys.loggedInGroups, groups);
    sharedPreferences.commit();

  }

  static setFollowGroup(String group, {bool follow = true, bool notifications = true}){
    if (!follow) notifications = false;

    // Save is sth is changed...
    bool updateFeed = false;
    bool changedSth = false;

    // Get current lists...
    List<String> currentFollowingList = sharedPreferences.getStringList(Keys.feedGroups) ?? [];
    List<String> currentNotificationList = sharedPreferences.getStringList(Keys.notificationGroups) ?? [];

    // Update following if it's a new state...
    if (follow && !currentFollowingList.contains(group)) {
      currentFollowingList.add(group);
      notifications = true;
      updateFeed = true;
      changedSth = true;
    }
    else if (!follow && currentFollowingList.contains(group)) {
      currentFollowingList.remove(group);
      updateFeed = true;
      changedSth = true;
    }
    
    // Update notifications if it's a new state...
    if (notifications && !currentNotificationList.contains(group)) {
      currentNotificationList.add(group);
      changedSth = true;
    }
    else if (!notifications && currentNotificationList.contains(group)) {
      currentNotificationList.remove(group);
      changedSth = true;
    }

    // Set new lists...
    sharedPreferences.setStringList(Keys.feedGroups, currentFollowingList.toList());
    sharedPreferences.setStringList(Keys.notificationGroups, currentNotificationList.toList());

    // Update tags if required...
    if (changedSth) {
      if (!follow) OneSignal.shared.deleteTag(Keys.messageboardGroupTag(group));
      else OneSignal.shared.sendTag(Keys.messageboardGroupTag(group), notifications);
    }

    // Update the feed if required...
    if (updateFeed) feed.update();
  }

  /// Checks if any waiting group changed it's status...
  static void updateGroupsStates(){
    List<Group> myWaitingGroups = waiting;
    List<String> allAcceptedGroupNames = Messageboard.publicGroups.map((group) => group.name).toList();
    List<String> allBlockedGroupNames = Messageboard.blockedGroups.map((group) => group.name).toList();

    myWaitingGroups.forEach((group) {
      if (allAcceptedGroupNames.contains(group.name)) confirmWaitingGroup(group.name);
      else if (allBlockedGroupNames.contains(group.name)) blockWaitingGroup(group.name);
    });
  }

}

/// Describes the login information...
class MessageboardError {
  final String error;

  MessageboardError({this.error});

  factory MessageboardError.fromJson(Map<String, dynamic> json) {
    return MessageboardError(
      error: json['error'] as String,
    );
  }
}

/// Defines a messageboard group...
class Group {
  final String name;
  String password;
  String info;
  String status;
  int follower;
  Function(String status) statusListener;
  int currentUpdateProcesses = 0;
  List<Post> posts = [];
  bool loadComplete = false;
  bool isAdding = false;
  bool isUpdating = false;
  List<Function()> addedListeners = [];
  List<Function()> updatedListeners = [];

  Group({this.name, this.password, this.info, this.status, this.follower});

  /// Creates a json string of this group...
  String toJson() {
    return json.encode({'username': name, 'password': password, 'info': info, 'status': status});
  }

  /// Updates the object and the group on the api...
  Future<bool> update(SharedPreferences sharedPreferences, {String newInfo, String newPassword}) async {
    info = newInfo ?? info;
    password = newPassword ?? sharedPreferences.getString(Keys.groupEditPassword(name));
    bool updated = await data.updateGroup(username: name, password: sharedPreferences.getString(Keys.groupEditPassword(name)), newInfo: info, newPassword: password);
    if (newInfo != null) {
      await data.downloadGroups();
      updatedListeners.forEach((updatedListener) => updatedListener());
    }
    return updated;
  }

  /// Reloads all posts...
  Future reloadPosts() async {
    await data.downloadPosts(this, start: 0, end: 10);
    addedListeners.forEach((addedListener) => addedListener());
  }

  /// Loads the next posts of this group...
  Future loadNew() async {
    await data.downloadPosts(this, start: posts.length, end: posts.length + 10, addPosts: true);
    addedListeners.forEach((addedListener) => addedListener());
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['username'] as String,
      password: json['password'] as String,
      info: json['info'] as String,
      status: json['status'] as String,
      follower: json['follower'] as int
    );
  }
}

class Feed {
  List<Post> posts;
  bool loadComplete = false;

  Feed({this.posts});

  Future<void> update() async {
    // Update data...
    await data.downloadFeed(addFeed: false);
  }

  void addFeed(Feed feed){
    this.posts.addAll(feed.posts);
  }

  Future<void> loadNew() async {
    await data.downloadFeed(start: posts.length, end: posts.length + 10, addFeed: true);
  }

  factory Feed.fromJson(List<dynamic> json){
    return Feed(
      posts: json.map((post) => Post.fromJson(post)).toList()
    );
  }
}

class Post {
  String title;
  String text;
  final String date;
  final String username;
  final String id;
  List<Function()> updatedListeners = [];

  Post({this.title, this.text, this.date, this.id, this.username});

  Future<void> delete(String password, {Function() onDeleted, Function() onFailed, String username}) async {
    bool deleted = await data.deletePost(id: id, password: password);
    if (deleted){
      await data.downloadFeed();
      Messageboard.allGroups.where((group) => group.name == (this.username == '' ? username : this.username)).toList()[0].posts = [];
      if (onDeleted != null) onDeleted();
    }
    else if (onFailed != null) onFailed();
  }

  Future<void> update(String password, String newTitle, String newText, {Function() onUpdated, Function() onFailed, String username}) async {
    bool updated = await data.updatePost(id: id, password: password, newTitle: newTitle ?? this.title, newText: newText ?? this.text);
    if (updated){
      this.title = newTitle;
      this.text = newText;
      await data.downloadFeed();
      await Messageboard.allGroups.where((group) => group.name == (this.username == '' ? username : this.username)).toList()[0].reloadPosts();
      if (onUpdated != null) onUpdated();
    }
    else if (onFailed != null) onFailed();
  }

  DateTime get dateTime{
    return DateTime.parse(date);
  }

  String get dateString {
    DateTime date = this.dateTime;
    DateTime now = DateTime.now();
    if (date.isBefore(now.subtract(Duration(days: 1)))) return '${date.day}.${date.month}.${date.year}';
    else {
      String hour = date.hour < 10 ? '0' + date.hour.toString() : date.hour.toString();
      String min = date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString();
      return '$hour:$min Uhr';
    }
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] as String,
      text: json['text'] as String,
      date: DateTime.parse(json['time'] as String).add(Duration(hours: 1)).toIso8601String(),
      id: json['id'] as String,
      username: json['username'] as String ?? '',
    );
  }
}
