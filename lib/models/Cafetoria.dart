class CafetoriaLogin {
  final String error;

  CafetoriaLogin({this.error});

  factory CafetoriaLogin.fromJson(Map<String, dynamic> json) {
    return CafetoriaLogin(
      error: json['error'] as String,
    );
  }
}

class Cafetoria {
  final String error;
  final List<CafetoriaDay> days;
  final double saldo;

  Cafetoria({this.error, this.days, this.saldo});

  factory Cafetoria.fromJson(Map<String, dynamic> json) {
    return Cafetoria(
        error: json['error'] as String,
        days: json['days']
            .toList()
            .map((day) => CafetoriaDay.fromJson(day))
            .toList()
            .cast<CafetoriaDay>(),
        saldo: double.parse('${json['saldo'] ?? -1.0}'));
  }
}

class CafetoriaDay {
  final String weekday;
  final String date;
  final List<CafetoriaMenu> menues;

  CafetoriaDay({this.weekday, this.date, this.menues});

  factory CafetoriaDay.fromJson(Map<String, dynamic> json) {
    return CafetoriaDay(
      weekday: json['weekday'] as String,
      date: json['date'] as String,
      menues: json['menues']
          .map((day) => CafetoriaMenu.fromJson(day))
          .toList()
          .cast<CafetoriaMenu>(),
    );
  }
}

class CafetoriaMenu {
  final String time;
  final String name;
  final double price;

  CafetoriaMenu({this.time, this.name, this.price});

  factory CafetoriaMenu.fromJson(Map<String, dynamic> json) {
    return CafetoriaMenu(
        time: json['time'] as String,
        name: json['name'] as String,
        price: double.parse('${json['price'] ?? 0.0}'));
  }
}
