import 'package:flutter/material.dart';
import 'package:login_1/src/core/services/database_service.dart';

class WorkerProfileViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  WorkerProfileViewModel(this._dbService) {
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
      _profileData = await _dbService.getWorkerProfile();
    } catch (e) {
      print('Error loading worker profile: \$e');
      _profileData = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String skill,
    required String experience,
    required String place,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.updateWorkerProfile(
        name: name,
        phone: phone,
        email: email,
        skill: skill,
        experience: experience,
        place: place,
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
