import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Client Auth ---

  Future<String> signupClient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception("Failed to create user in Firebase Auth.");
    }

    String clientId = await _generateUniqueClientId(name);

    await _firestore.collection('client').doc(clientId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'client',
      'clientId': clientId,
      'uid': userCredential.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return clientId;
  }

  Future<bool> loginClient(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) return false;

    final querySnapshot = await _firestore
        .collection('client')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await _auth.signOut();
      throw Exception("Client data not found");
    }

    final role = querySnapshot.docs.first.data()['role'];
    if (role != 'client') {
      await _auth.signOut();
      throw Exception("Unauthorized role: Access denied");
    }

    return true;
  }

  Future<String> _generateUniqueClientId(String name) async {
    final random = Random();
    String idPrefix = name.trim().toUpperCase().substring(0, min(3, name.length));
    String clientId = '';
    bool exists = true;

    while (exists) {
      String randomDigits = (10 + random.nextInt(90)).toString(); // 2-digit number
      clientId = idPrefix + randomDigits;

      final doc = await _firestore.collection('client').doc(clientId).get();
      exists = doc.exists;
    }

    return clientId;
  }

  // --- Worker Auth ---

  Future<void> signupWorker({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception("Failed to create user in Firebase Auth.");
    }

    final customUid = _generateCustomUid(name);

    await _firestore.collection('worker').doc(customUid).set({
      'customUid': customUid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'worker',
      'authUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> loginWorker(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) return false;

    final querySnapshot = await _firestore
        .collection('worker')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await _auth.signOut();
      throw Exception("Worker data not found");
    }

    final role = querySnapshot.docs.first.data()['role'];
    if (role != 'worker') {
      await _auth.signOut();
      throw Exception("Unauthorized role: Access denied");
    }

    return true;
  }

  String _generateCustomUid(String name) {
    String prefix = name.trim().toUpperCase().replaceAll(" ", "");
    if (prefix.length >= 3) {
      prefix = prefix.substring(0, 3);
    } else {
      prefix = prefix.padRight(3, 'X'); 
    }
    final rand = Random();
    final digits = rand.nextInt(90) + 10; 
    return '$prefix$digits';
  }

  // --- Shared ---

  Future<void> logout() async {
    await _auth.signOut();
  }
}
