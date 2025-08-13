import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class UserProvider extends ChangeNotifier {
  UserModel _loggedInUser = UserModel.empty();
  UserModel? _viewedCustomer;

  UserModel get loggedInUser => _loggedInUser;
  UserModel? get viewedCustomer => _viewedCustomer;
  UserRole get role => _loggedInUser.role;

  /// Set the logged in user (Admin, Dealer, etc.)
  void setLoggedInUser(UserModel user) {
    _loggedInUser = user;
    notifyListeners();
  }

  /// Set a customer currently being viewed
  void setViewedCustomer(UserModel customer) {
    _viewedCustomer = customer;
    notifyListeners();
  }

  /// Clear the viewed customer
  void clearViewedCustomer() {
    _viewedCustomer = null;
    notifyListeners();
  }

  /// Update the user info if they are logged in or viewed
  void updateUser(UserModel updatedUser) {
    if (_loggedInUser.id == updatedUser.id) {
      _loggedInUser = updatedUser;
      if (_viewedCustomer?.id == updatedUser.id) {
        _viewedCustomer = updatedUser;
      }
    } else if (_viewedCustomer?.id == updatedUser.id) {
      _viewedCustomer = updatedUser;
    }
    notifyListeners();
  }

  /// Change role dynamically
  void changeRole(UserRole newRole) {
    if (_loggedInUser.role != newRole) {
      _loggedInUser = _loggedInUser.copyWith(role: newRole);
      notifyListeners();
    }
  }

  /// Reset provider to default state
  void resetUser() {
    _loggedInUser = UserModel.empty();
    _viewedCustomer = null;
    notifyListeners();
  }
}

/*
class UserProvider extends ChangeNotifier {
  UserModel _loggedInUser = UserModel.empty();
  UserModel? _viewedCustomer;

  UserModel get loggedInUser => _loggedInUser;
  UserModel? get viewedCustomer => _viewedCustomer;
  UserRole get role => _loggedInUser.role;

  void setLoggedInUser(UserModel user) {
    _loggedInUser = user;
    notifyListeners();
  }

  void setViewedCustomer(UserModel customer) {
    _viewedCustomer = customer;
    notifyListeners();
  }

  void clearViewedCustomer() {
    _viewedCustomer = null;
    notifyListeners();
  }

  void updateUser(UserModel updatedUser) {
    if (_loggedInUser.id == updatedUser.id) {
      _loggedInUser = updatedUser;
      _viewedCustomer = updatedUser;
    } else if (_viewedCustomer?.id == updatedUser.id) {
      _viewedCustomer = updatedUser;
    }
    notifyListeners();
  }
}*/
