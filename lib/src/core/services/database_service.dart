import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Client Home ---
  Future<String> getClientName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('clients').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['name']?.toString() ?? 'User';
      }
      
      DocumentSnapshot userDoc2 = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc2.exists) {
        Map<String, dynamic> userData = userDoc2.data() as Map<String, dynamic>;
        return userData['name']?.toString() ?? 'User';
      }
      
      return user.email?.split('@')[0] ?? 'User';
    }
    return 'User';
  }

  Future<List<Map<String, dynamic>>> getWorkersBySkill(String skill) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('worker')
        .where('skill', isEqualTo: skill)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Store document ID just in case
      return data;
    }).toList();
  }

  Future<void> sendRequestToWorker(Map<String, dynamic> workerData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    String clientName = user.displayName ?? user.email?.split('@')[0] ?? 'Unknown Client';
    String clientContact = user.email ?? 'Unknown Contact';
    String workerPhone = workerData['phone'] ?? 'Unknown Phone';

    // Check if a request already exists to this worker
    final snapshot = await _realtimeDb.ref('requests').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (var request in data.values) {
        if (request['clientContact'] == clientContact && request['workerPhone'] == workerPhone) {
          throw Exception("u arer requesting morethan once");
        }
      }
    }

    DatabaseReference requestRef = _realtimeDb.ref('requests').push();
    await requestRef.set({
      'workerName': workerData['name'],
      'workerSkill': workerData['skill'],
      'workerPhone': workerPhone,
      'clientName': clientName,
      'clientContact': clientContact,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'Pending',
    });
  }

  // --- Client Requests ---
  Stream<DatabaseEvent> getRequestsStream() {
    return _realtimeDb.ref('requests').onValue;
  }

  Future<void> rejectRequest(String requestKey) async {
    await _realtimeDb.ref('requests/$requestKey').remove();
  }

  Future<void> acceptRequest(String requestKey) async {
    await _realtimeDb.ref('requests/$requestKey').update({'status': 'Accepted'});
  }

  Future<void> rateWorker({
    required String requestKey,
    required String workerName,
    required int rating,
    required String review,
    required String clientName,
  }) async {
    await _realtimeDb.ref('ratings/$requestKey').set({
      'workerName': workerName,
      'clientName': clientName,
      'rating': rating,
      'review': review,
      'timestamp': ServerValue.timestamp,
    });
  }

  // --- Client Profile ---
  Future<Map<String, dynamic>?> getClientProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    // Client docs are stored in 'client' collection with uid field
    final qs = await _firestore
        .collection('client')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) {
      return qs.docs.first.data();
    }

    return {
      'name': user.displayName ?? '',
      'email': user.email ?? '',
    };
  }

  Future<void> updateClientProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String password,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Find the client's existing document (doc ID is a custom string, not uid)
    final qs = await _firestore
        .collection('client')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) throw Exception("Client profile not found");

    await qs.docs.first.reference.update({
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    if (password.isNotEmpty) {
      await user.updatePassword(password);
    }
  }

  // --- Worker Profile/Home ---
  Future<Map<String, dynamic>?> getWorkerProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    // Worker docs use a custom ID (e.g. "JOH42"), not the Auth UID.
    // Always query by authUid field to find the correct document.
    final qs = await _firestore
        .collection('worker')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) {
      return qs.docs.first.data();
    }

    return {
      'name': user.displayName ?? '',
      'email': user.email ?? '',
    };
  }

  Future<void> updateWorkerProfile({
    required String name,
    required String phone,
    required String email,
    required String skill,
    required String experience,
    required String place,
    required String password,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Worker docs use a custom ID — find the existing doc by authUid
    final qs = await _firestore
        .collection('worker')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) throw Exception("Worker profile not found");

    // Update the EXISTING document, never create a new one
    await qs.docs.first.reference.update({
      'name': name,
      'phone': phone,
      'email': email,
      'skill': skill,
      'experience': experience,
      'place': place,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    if (password.isNotEmpty) {
      await user.updatePassword(password);
    }
  }

  Future<void> updateWorkerAvailability(bool isAvailable) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final qs = await _firestore
        .collection('worker')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) {
      await qs.docs.first.reference.update({
        'isAvailable': isAvailable,
      });
    }
  }

  Stream<DatabaseEvent> getRTDBRatingsStream() {
    return _realtimeDb.ref('ratings').onValue;
  }

  Stream<QuerySnapshot> getFirestoreRatingsStream() {
    return _firestore.collection('ratings').snapshots();
  }

  // --- Chat ---
  Stream<DatabaseEvent> getChatMessages(String requestKey) {
    return _realtimeDb.ref('chats/$requestKey').orderByChild('timestamp').onValue;
  }

  Future<void> sendMessage({
    required String requestKey,
    required String text,
    required String senderId,
    required String senderName,
    required String senderRole,
  }) async {
    DatabaseReference chatRef = _realtimeDb.ref('chats/$requestKey').push();
    await chatRef.set({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'timestamp': ServerValue.timestamp,
    });
  }
}
