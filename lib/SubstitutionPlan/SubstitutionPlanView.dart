import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Update.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Widgets/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanDayList/SubstitutionPlanDayListWidget.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanPage.dart';

// ignore: public_member_api_docs
class SubstitutionPlanPageView extends SubstitutionPlanPageState {
  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return Container();
    }
    return TabProxy(
      weekdays: weekdays,
      tabs: days
          .map((day) => SubstitutionPlanDayList(
                day: day,
                dayIndex: days.indexOf(day),
                grade: Storage.getString(Keys.grade),
              ))
          .toList(),
      controller: controller,
      onUpdate: () async {
        await syncWithTags();
        final bool successfully =
            await SubstitutionPlanData().download(context) ==
                StatusCodes.success;
        dataUpdated(context, successfully,
            AppLocalizations.of(context).substitutionPlan);
        setState(() => days = generateDays(Data.substitutionPlan.days));
      },
    );
  }
}
