import 'package:flutter/material.dart';
import '../utils/enums.dart';

class UserProvider extends ChangeNotifier {
  UserRole _role = UserRole.customer; // Default

  UserRole get role => _role;

  void setRole(UserRole newRole) {
    _role = newRole;
    notifyListeners();
  }
}