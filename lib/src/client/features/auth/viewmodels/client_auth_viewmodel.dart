import 'package:flutter/material.dart';
import 'package:login_1/src/core/services/auth_service.dart';

class ClientAuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  ClientAuthViewModel(this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _authService.loginClient(email, password);
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signupClient(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  String _parseErrorMessage(dynamic e) {
    // This could be more sophisticated based on FirebaseAuthException codes
    return e.toString();
  }
}
