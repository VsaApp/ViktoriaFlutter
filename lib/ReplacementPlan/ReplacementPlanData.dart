import 'package:shared_preferences/shared_preferences.dart';

import 'ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanModel.dart';

Future<List<ReplacementPlanDay>> load(List<UnitPlanDay> _days, bool temp) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<ReplacementPlanDay> days = _days.where((day) => day.replacementPlanForWeekday != '').map((day) => day.getReplacementPlanDay(sharedPreferences)).toList();
  days.forEach((day) => day.setColors());

  // Return or set the data in a static object...
  if (!(temp ?? false)) {
    ReplacementPlan.days = days;
  }
  else
    return days;
  return null;
}

// Returns the static replacement plan...
List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}
