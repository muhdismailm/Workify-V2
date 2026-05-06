import 'package:flutter/material.dart';
import 'package:login_1/src/core/services/database_service.dart';

class ClientHomeViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  ClientHomeViewModel(this._dbService) {
    _init();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _clientName = 'User';
  String get clientName => _clientName;

  String? _selectedSkill;
  String? get selectedSkill => _selectedSkill;

  List<Map<String, dynamic>> _workers = [];
  List<Map<String, dynamic>> get workers => _workers;

  Future<void> _init() async {
    _clientName = await _dbService.getClientName();
    notifyListeners();
  }

  Future<void> selectSkill(String? skill) async {
    _selectedSkill = skill;
    notifyListeners();
    
    if (skill != null) {
      await fetchWorkers(skill);
    }
  }

  Future<void> fetchWorkers(String skill) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workers = await _dbService.getWorkersBySkill(skill);
    } catch (e) {
      print("Error fetching workers: \$e");
      _workers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendRequest(Map<String, dynamic> workerData) async {
    try {
      await _dbService.sendRequestToWorker(workerData);
      return true;
    } catch (e) {
      print('Error sending request: \$e');
      return false;
    }
  }
}
