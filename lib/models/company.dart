class Company {
  final String id;
  final String name;
  final bool active;

  Company({
    required this.id,
    required this.name,
    required this.active,
  });

  factory Company.fromFirestore(String id, Map<String, dynamic> data) {
    return Company(
      id: id,
      name: data['name'],
      active: data['active'] ?? true,
    );
  }
}
