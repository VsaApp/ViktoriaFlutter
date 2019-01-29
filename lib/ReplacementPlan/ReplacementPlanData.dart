import 'ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanModel.dart';

Future<List<ReplacementPlanDay>> load(
    List<UnitPlanDay> _days, bool temp) async {
  List<ReplacementPlanDay> days = [];
  _days
      .where((day) => day.replacementPlanForWeekday != '')
      .forEach((day) async {
    days.add(await day.getReplacementPlanDay());
  });
  days.forEach((day) => day.setColors());

  // Return or set the data in a static object...
  if (!(temp ?? false))
    ReplacementPlan.days = days;
  else
    return days;
  return null;
}

// Returns the static replacement plan...
List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}
