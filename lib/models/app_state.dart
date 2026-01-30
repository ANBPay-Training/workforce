import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String? companyId;
  String? role;

  void setUserData({required String companyId, required String role}) {
    this.companyId = companyId;
    this.role = role;
    notifyListeners();
  }
}
