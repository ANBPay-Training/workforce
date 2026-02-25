class Employee {
  final String id;

  // Personal info
  final String name;
  final String email;
  final String role; // employee | supervisor
  final String accessCode;
  final bool active;

  // Employment relation
  final List<String> companyIds; // companies this employee can work for

  // Work state
  final bool isWorking;
  final String? activeCompanyId; // where currently working
  final String? activeBranchId; // which branch currently working

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessCode,
    required this.active,
    required this.companyIds,
    required this.isWorking,
    this.activeCompanyId,
    this.activeBranchId,
  });

  factory Employee.fromFirestore(String id, Map<String, dynamic> data) {
    return Employee(
      id: id,
      name: data['name'],
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      accessCode: data['accessCode'],
      active: data['active'] ?? true,
      companyIds: List<String>.from(data['companyIds'] ?? []),
      isWorking: data['isWorking'] ?? false,
      activeCompanyId: data['activeCompanyId'],
      activeBranchId: data['activeBranchId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'accessCode': accessCode,
      'active': active,
      'companyIds': companyIds,
      'isWorking': isWorking,
      'activeCompanyId': activeCompanyId,
      'activeBranchId': activeBranchId,
    };
  }
}
