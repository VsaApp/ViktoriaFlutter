import 'dart:convert';

import 'package:viktoriaflutter/Downloader/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Models/Models.dart';

/// Work groups data downloader
class WorkGroupsData extends Downloader<WorkGroups> {
  // ignore: public_member_api_docs
  WorkGroupsData()
      : super(
          url: Urls.workgroups,
          key: Keys.workGroups,
          defaultData: [],
        );

  @override
  WorkGroups getData() {
    return Data.workGroups;
  }

  @override
  void saveStatic(WorkGroups data) {
    Data.workGroups = data;
  }

  @override
  WorkGroups parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return WorkGroups(
      days: parsed
          .map<WorkGroupsDay>((json) => WorkGroupsDay.fromJson(json))
          .toList(),
    );
  }
}
