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

  Future<void> rateWorker(String requestKey, String workerName, int rating) async {
    await _realtimeDb.ref('ratings/$requestKey').set({
      'workerName': workerName,
      'rating': rating,
    });
  }

  // --- Client Profile ---
  Future<Map<String, dynamic>?> getClientProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
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

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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

    DocumentSnapshot userDoc = await _firestore.collection('worker').doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    
    // Also try checking by authUid just in case the document ID is not uid
    QuerySnapshot qs = await _firestore.collection('worker').where('authUid', isEqualTo: user.uid).limit(1).get();
    if (qs.docs.isNotEmpty) {
      return qs.docs.first.data() as Map<String, dynamic>;
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

    await _firestore.collection('worker').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'skill': skill,
      'experience': experience,
      'place': place,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }
    
    if (password.isNotEmpty) {
      await user.updatePassword(password);
    }
  }

  Stream<DatabaseEvent> getRTDBRatingsStream() {
    return _realtimeDb.ref('ratings').onValue;
  }

  Stream<QuerySnapshot> getFirestoreRatingsStream() {
    return _firestore.collection('ratings').snapshots();
  }
}
