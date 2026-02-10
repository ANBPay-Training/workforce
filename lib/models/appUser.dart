class AppUser {
  final String id;
  final String email;
  final String role;
  final List<String> companyIds;
  final bool active;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.companyIds,
    required this.active,
  });

  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'],
      role: data['role'],
      companyIds: List<String>.from(data['companyIds'] ?? []),
      active: data['active'] ?? true,
    );
  }
}
