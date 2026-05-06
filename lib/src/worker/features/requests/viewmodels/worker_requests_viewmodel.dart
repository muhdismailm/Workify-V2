import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_1/src/core/services/database_service.dart';

class WorkerRequestsViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  WorkerRequestsViewModel(this._dbService);

  Stream<DatabaseEvent> getRequestsStream() {
    return _dbService.getRequestsStream();
  }

  Future<bool> rejectRequest(String requestKey) async {
    try {
      await _dbService.rejectRequest(requestKey);
      return true;
    } catch (e) {
      print('Error rejecting request: \$e');
      return false;
    }
  }

  Future<bool> acceptRequest(String requestKey) async {
    try {
      await _dbService.acceptRequest(requestKey);
      return true;
    } catch (e) {
      print('Error accepting request: \$e');
      return false;
    }
  }
}
