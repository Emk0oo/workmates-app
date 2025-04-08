class Session {
  int id;
  String name;
  String addressNumber;
  String streetName;
  String zipCode;
  String city;
  DateTime startDate;
  DateTime endDate;
  int? userId;

  Session({
    required this.id,
    required this.name,
    required this.addressNumber,
    required this.streetName,
    required this.zipCode,
    required this.city,
    required this.startDate,
    required this.endDate,
    this.userId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? 0,
      name: json['nom'] ?? "",
      addressNumber: json['adresse_numero'] ?? "",
      streetName: json['adresse_rue'] ?? "",
      zipCode: json['code_postal'] ?? "",
      city: json['ville'] ?? "",
      startDate: DateTime.parse(json['date_debut'] ?? "1970-01-01T00:00:00Z"),
      endDate: DateTime.parse(json['date_fin'] ?? "1970-01-01T00:00:00Z"),
      userId: json['user_id'], // Peut être null donc pas de fallback
    );
  }
}
