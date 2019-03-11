import 'package:shared_preferences/shared_preferences.dart';

import '../UnitPlan/UnitPlanModel.dart';
import 'ReplacementPlanModel.dart';

Future<List<ReplacementPlanDay>> load(
    List<UnitPlanDay> _days, bool temp) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<ReplacementPlanDay> days = _days
      .where((day) => day.replacementPlanForWeekday != '')
      .map((day) => day.getReplacementPlanDay(sharedPreferences))
      .toList();

  // Return or set the data in a static object...
  if (!(temp ?? false)) {
    ReplacementPlan.days = days;
    return null;
  } else {
    return days;
  }
}

// Returns the static replacement plan...
List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}
