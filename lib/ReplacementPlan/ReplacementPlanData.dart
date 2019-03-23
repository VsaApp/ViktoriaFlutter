import '../UnitPlan/UnitPlanModel.dart';
import 'ReplacementPlanModel.dart';

List<ReplacementPlanDay> load(List<UnitPlanDay> _days, bool temp) {
  List<ReplacementPlanDay> days = _days
      .where((day) => day.replacementPlanForWeekday != '')
      .map((day) => day.getReplacementPlanDay())
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
