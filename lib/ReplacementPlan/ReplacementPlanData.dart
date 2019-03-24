import '../UnitPlan/UnitPlanModel.dart';
import 'ReplacementPlanModel.dart';

List<ReplacementPlanDay> load(List<UnitPlanDay> _days, bool temp) {
  List<ReplacementPlanDay> days = _days
      .where((day) => day.replacementPlanForWeekday != '')
      .map((day) => day.getReplacementPlanDay())
      .toList();

  // Return or set the data in a static object...
  if (!(temp ?? false)) {
    days.sort((a, b) =>
        DateTime(int.parse(a.date.split('.')[2]),
            int.parse(a.date.split('.')[1]), int.parse(a.date.split('.')[0]))
            .compareTo(DateTime(int.parse(b.date.split('.')[2]),
            int.parse(b.date.split('.')[1]), int.parse(b.date.split('.')[0]))));
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
