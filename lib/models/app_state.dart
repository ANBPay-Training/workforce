class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? role;
  String? userId;

  void setUser(String role, String userId) {
    this.role = role;
    this.userId = userId;
  }

  void setUserRole(String role) {
    this.role = role;
    this.userId = userId;
  }

  void clear() {
    role = null;
    userId = null;
  }
}
