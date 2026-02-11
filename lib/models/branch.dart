class Branch {
  final String id;
  final String companyId;
  final String name;
  final bool active;

  Branch(
      {required this.id,
      required this.companyId,
      required this.name,
      required this.active});

  factory Branch.fromFirestore(String id, Map<String, dynamic> data) {
    return Branch(
      id: id,
      companyId: data['companyId'],
      name: data['name'],
      active: data['active'] ?? true,
    );
  }
}
