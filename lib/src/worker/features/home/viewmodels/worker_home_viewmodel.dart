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

  Future<void> _init() async {
    final profile = await _dbService.getWorkerProfile();
    if (profile != null) {
      _workerName = profile['name']?.toString();
      _workerSkill = profile['skill']?.toString();
      notifyListeners();
    }
  }

  Stream<DatabaseEvent> getRTDBRatingsStream() {
    return _dbService.getRTDBRatingsStream();
  }

  Stream<QuerySnapshot> getFirestoreRatingsStream() {
    return _dbService.getFirestoreRatingsStream();
  }
}
