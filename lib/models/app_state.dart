class AppState {
  // Create a single shared instance of AppState (Singleton pattern)
  static final AppState _instance = AppState._internal();

  // Factory constructor always returns the same instance
  factory AppState() => _instance;

  // Private constructor so no other instance can be created
  AppState._internal();

  String? userId;
  String? role;
  String? companyName;

  // Indicates whether the user is currently logged in
  bool get isLoggedIn => userId != null;

  // Indicates whether the logged-in user is an admin
  bool get isAdmin => role == 'admin';

  // Indicates whether the logged-in user is a company
  bool get isCompany => role == 'company';

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
  }

  /// Clears all stored user data (used during logout)
  void clear() {
    userId = null;
    role = null;
    companyName = null;
  }
}
