class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? role;

  void setUserRole(String role) {
    this.role = role;
  }

  void clear() {
    role = null;
  }
}
