/// Describes the login information...
class CafetoriaLogin {
  /// Login error
  final String error;

  // ignore: public_member_api_docs
  CafetoriaLogin({this.error});

  /// Creates a cafetoria login from json map
  factory CafetoriaLogin.fromJson(Map<String, dynamic> json) {
    return CafetoriaLogin(
      error: json['error'] as String,
    );
  }
}

/// Describes the whole Cafetoria data...
class Cafetoria {
  /// The login errors
  final String error;

  /// All cafetoria days
  final List<CafetoriaDay> days;

  /// The user saldo
  final double saldo;

  // ignore: public_member_api_docs
  Cafetoria({this.error, this.days, this.saldo});

  /// Creates cafetoria from json map
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

/// Describes a day of the cafetoria...
class CafetoriaDay {
  /// The day index
  final int day;

  /// The day [date]
  final String date;

  /// The day [menus]
  final List<CafetoriaMenu> menus;

  // ignore: public_member_api_docs
  CafetoriaDay({this.day, this.date, this.menus});

  /// Creates a cafetoria day from json map
  factory CafetoriaDay.fromJson(Map<String, dynamic> json) {
    return CafetoriaDay(
      day: json['day'] as int,
      date: json['date'] as String,
      menus: json['menus']
          .map((day) => CafetoriaMenu.fromJson(day))
          .toList()
          .cast<CafetoriaMenu>(),
    );
  }
}

/// Describes a menu of a day...
class CafetoriaMenu {
  /// The time of this menu
  final String time;

  /// The name of this menu
  final String name;

  /// The price of this menu
  final double price;

  // ignore: public_member_api_docs
  CafetoriaMenu({this.time, this.name, this.price}) : super();

  /// Creates a cafetoria menu from json map
  factory CafetoriaMenu.fromJson(Map<String, dynamic> json) {
    return CafetoriaMenu(
        time: json['time'] as String,
        name: json['name'] as String,
        price: double.parse('${json['price'] ?? 0.0}'));
  }
}
