// Describes the login information...

class Cafetoria {
  static CafetoriaMenus menus;
}

class CafetoriaLogin {
  final String error;

  CafetoriaLogin({this.error});

  factory CafetoriaLogin.fromJson(Map<String, dynamic> json) {
    return CafetoriaLogin(
      error: json['error'] as String,
    );
  }
}

// Describes the whole Cafetoria data...
class CafetoriaMenus {
  final String error;
  final List<CafetoriaDay> days;
  final double saldo;

  CafetoriaMenus({this.error, this.days, this.saldo});

  factory CafetoriaMenus.fromJson(Map<String, dynamic> json) {
    return CafetoriaMenus(
        error: json['error'] as String,
        days: json['days']
            .toList()
            .map((day) => CafetoriaDay.fromJson(day))
            .toList()
            .cast<CafetoriaDay>(),
        saldo: double.parse('${json['saldo'] ?? -1.0}'));
  }
}

// Describes a day of the cafetoria...
class CafetoriaDay {
  final String weekday;
  final String date;
  final List<CafetoriaMenu> menus;

  CafetoriaDay({this.weekday, this.date, this.menus});

  factory CafetoriaDay.fromJson(Map<String, dynamic> json) {
    return CafetoriaDay(
      weekday: json['weekday'] as String,
      date: json['date'] as String,
      menus: json['menus']
          .map((day) => CafetoriaMenu.fromJson(day))
          .toList()
          .cast<CafetoriaMenu>(),
    );
  }
}

// Describes a menu of a day...
class CafetoriaMenu {
  final String time;
  final String name;
  final double price;

  CafetoriaMenu({this.time, this.name, this.price}):super();

  factory CafetoriaMenu.fromJson(Map<String, dynamic> json) {
    return CafetoriaMenu(
        time: json['time'] as String,
        name: json['name'] as String,
        price: double.parse('${json['price'] ?? 0.0}'));
  }
}
