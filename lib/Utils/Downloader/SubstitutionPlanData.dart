import 'dart:convert';

import 'package:viktoriaflutter/Utils/Downloader.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class SubstitutionPlanData extends Downloader<SubstitutionPlan> {
  SubstitutionPlanData()
      : super(
          url: Urls.substitutionPlan,
          key: Keys.substitutionPlan,
          defaultData: [],
        );

  @override
  SubstitutionPlan getData() {
    return Data.substitutionPlan;
  }

  @override
  void saveStatic(SubstitutionPlan data) {
    Data.substitutionPlan = data;
  }

  @override
  SubstitutionPlan parse(String responseBody) {
    final parsed = json.decode(responseBody);
    return SubstitutionPlan(
      days: parsed
          .map<SubstitutionPlanDay>((day) => SubstitutionPlanDay.fromJson(day))
          .toList(),
    );
  }
}