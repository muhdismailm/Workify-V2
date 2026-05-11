import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_1/src/core/services/database_service.dart';

class ClientRequestsViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  ClientRequestsViewModel(this._dbService);

  Stream<DatabaseEvent> getRequestsStream() {
    return _dbService.getRequestsStream();
  }

  Future<bool> rejectRequest(String requestKey) async {
    try {
      await _dbService.rejectRequest(requestKey);
      return true;
    } catch (e) {
      print('Error rejecting request: $e');
      return false;
    }
  }

  Future<bool> submitRating({
    required String requestKey,
    required String workerName,
    required int rating,
    required String review,
    required String clientName,
  }) async {
    try {
      await _dbService.rateWorker(
        requestKey: requestKey,
        workerName: workerName,
        rating: rating,
        review: review,
        clientName: clientName,
      );
      return true;
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }
}
