import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getUserRole(String uid, {String? email}) async {
    final sw = Stopwatch()..start();
    log('==== getUserRole START | uid=$uid | email=$email ====');

    // ── STAGE 1: Document ID == UID (the correct path) ──────────────────────
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception("Firestore query timed out.");
      });
      log('STAGE1 doc.exists=${doc.exists}');
      if (doc.exists) {
        final role = doc.get('role') as String?;
        log('STAGE1 role=$role');
        return role;
      }
    } catch (e) {
      log('STAGE1 failed: $e');
    }

    // ── STAGE 2: Query by uid FIELD (handles Document ID typos) ─────────────
    try {
      final q = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get().timeout(const Duration(seconds: 5), onTimeout: () {
            throw Exception("Firestore query timed out.");
          });
      log('STAGE2 docs=${q.docs.length}');
      if (q.docs.isNotEmpty) {
        final role = q.docs.first.get('role') as String?;
        log('STAGE2 role=$role');
        return role;
      }
    } catch (e) {
      log('STAGE2 failed: $e');
    }

    log('==== getUserRole END — no document found | Time: ${sw.elapsedMilliseconds}ms ====');
    return null;
  }


  Future<void> saveFcmToken(String uid) async {
    try {
      String? token = await _messaging.getToken().timeout(const Duration(seconds: 3));
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      log('Error saving FCM token: $e');
    }
  }

  Future<UserCredential> registerClient(String name, String email, String password) async {
    final sw = Stopwatch()..start();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Registration timed out. Please check emulator internet connection.");
      });

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'role': 'client',
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception("Saving user data timed out.");
        });

        await _messaging.unsubscribeFromTopic('admins');
        // Fire and forget FCM token save to avoid blocking registration
        saveFcmToken(uid);
      }

      log('registerClient Execution Time: ${sw.elapsedMilliseconds}ms');
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> loginClient(String email, String password) async {
    final sw = Stopwatch()..start();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Login timed out. Please check emulator internet connection.");
      });

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String? role = await getUserRole(uid, email: email);

        if (role != 'client') {
          await _auth.signOut();
          throw Exception('Please use Agent Login.');
        }

        await _messaging.unsubscribeFromTopic('admins');
        saveFcmToken(uid);
      }
      log('loginClient Execution Time: ${sw.elapsedMilliseconds}ms');
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> loginAdmin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Login timed out. Please check emulator internet connection.");
      });

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String? role = await getUserRole(uid, email: email);

        if (role != 'admin') {
          await _auth.signOut();
          throw Exception('Access denied. You are not an admin.');
        }

        await _messaging.subscribeToTopic('admins');
        saveFcmToken(uid);
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _messaging.unsubscribeFromTopic('admins');
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
