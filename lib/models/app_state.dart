class AppState {
  // Create a single shared instance of AppState (Singleton pattern)
  static final AppState _instance = AppState._internal();

  // Factory constructor always returns the same instance
  factory AppState() => _instance;

  // Private constructor so no other instance can be created
  AppState._internal();

  String? userId;
  String? role;

  // Company/Admin info
  String? companyName;

  // Employee info
  String? employeeName;
  List<String>? companyIds;

  // Indicates whether the user is currently logged in
  bool get isLoggedIn => userId != null;

  // Indicates whether the logged-in user is an admin
  bool get isAdmin => role == 'admin';

  // Indicates whether the logged-in user is a company
  bool get isCompany => role == 'company';

  // Indicates whether the logged-in user is a employee
  bool get isEmployee => role == 'employee';

  bool isWorking = false;
  String? activeCompanyId;
  String? activeBranchId;

  /// Sets the logged-in company or admin user data
  void setCompanyUser({
    required String authUserId,
    required String role,
    required String companyName,
  }) {
    // Save the Firebase UID
    userId = authUserId;

    // Save the role (admin or company)
    this.role = role;

    // Save the company name (admin can ignore this)
    this.companyName = companyName;
    // Clear employee data
    employeeName = null;
    companyIds = null;
  }

  /// Employee login
  void setEmployeeUser({
    required String authUserId,
    required String role,
    required String employeeName,
    required List<String> companyIds,
    required bool isWorking,
    String? activeCompanyId,
    String? activeBranchId,
  }) {
    userId = authUserId;
    this.role = role;
    this.employeeName = employeeName;
    this.companyIds = companyIds;

    this.isWorking = isWorking;
    this.activeCompanyId = activeCompanyId;
    this.activeBranchId = activeBranchId;

    companyName = null;
  }

  /// Clears all stored user data (used during logout)
  void clear() {
    userId = null;
    role = null;
    companyName = null;
    employeeName = null;
    companyIds = null;
  }
}
