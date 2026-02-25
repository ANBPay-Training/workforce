class Branch {
  final String id;
  final String name;
  final bool active;

  Branch({
    required this.id,
    required this.name,
    required this.active,
  });

  factory Branch.fromFirestore(String id, Map<String, dynamic> data) {
    return Branch(
      id: id,
      name: data['name'],
      active: data['active'] ?? true,
    );
  }
}
