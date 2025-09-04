import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _currentUser = '';

  bool get isAuthenticated => _isAuthenticated;
  String get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation - in real app, this would be server-side
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _currentUser = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6 && phone.isNotEmpty) {
      _isAuthenticated = true;
      _currentUser = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = '';
    notifyListeners();
  }
}