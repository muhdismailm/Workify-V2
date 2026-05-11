import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_1/src/core/services/database_service.dart';

class WorkerHomeViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  WorkerHomeViewModel(this._dbService) {
    _init();
  }

  String? _workerName;
  String? get workerName => _workerName;

  String? _workerSkill;
  String? get workerSkill => _workerSkill;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> _init() async {
    final profile = await _dbService.getWorkerProfile();
    if (profile != null) {
      _workerName = profile['name']?.toString();
      _workerSkill = profile['skill']?.toString();
      _isAvailable = profile['isAvailable'] as bool? ?? false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(bool value) async {
    _isAvailable = value;
    notifyListeners();
    try {
      await _dbService.updateWorkerAvailability(value);
    } catch (e) {
      // Revert on error
      _isAvailable = !value;
      notifyListeners();
    }
  }

  Stream<DatabaseEvent> getRequestsStream() {
    return _dbService.getRequestsStream();
  }

  Future<bool> acceptRequest(String requestKey) async {
    try {
      await _dbService.acceptRequest(requestKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(String requestKey) async {
    try {
      await _dbService.rejectRequest(requestKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<DatabaseEvent> getRTDBRatingsStream() {
    return _dbService.getRTDBRatingsStream();
  }

  Stream<QuerySnapshot> getFirestoreRatingsStream() {
    return _dbService.getFirestoreRatingsStream();
  }
}
