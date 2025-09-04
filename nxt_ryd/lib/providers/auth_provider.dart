import 'package:flutter/foundation.dart';
import '../helpers/database_helper.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _currentUser = '';

  bool get isAuthenticated => _isAuthenticated;
  String get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.loginUser(email, password);
      
      if (user != null) {
        _currentUser = user['email'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final dbHelper = DatabaseHelper();
      
      // Check if user already exists
      if (await dbHelper.userExists(email)) {
        return false;
      }
      
      // Register new user
      final success = await dbHelper.registerUser(
        email: email,
        password: password,
        fullName: name,
        phoneNumber: phone,
      );
      
      if (success) {
        _currentUser = email;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = '';
    notifyListeners();
  }
}