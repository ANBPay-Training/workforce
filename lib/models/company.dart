class Company {
  final String id;
  final String email;
  final String role;
  final bool active;
  final String name;

  Company({
    required this.id,
    required this.email,
    required this.role,
    required this.active,
    required this.name,
  });

  factory Company.fromFirestore(String id, Map<String, dynamic> data) {
    return Company(
      id: id,
      email: data['email'],
      role: data['role'] ?? 'company',
      active: data['active'] ?? true,
      name: data['name'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'active': active,
      'name': name,
    };
  }
}
