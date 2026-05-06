import 'package:flutter/material.dart';
import 'package:login_1/src/core/services/database_service.dart';

class ClientProfileViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  ClientProfileViewModel(this._dbService) {
    loadProfile();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profileData = await _dbService.getClientProfile();
    } catch (e) {
      print('Error loading profile: \$e');
      _profileData = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.updateClientProfile(
        name: name,
        phone: phone,
        email: email,
        address: address,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
