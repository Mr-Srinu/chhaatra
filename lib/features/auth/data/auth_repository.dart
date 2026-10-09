import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/usermodel.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await UserModel.clearPrefs();
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('Email', isEqualTo: email.trim().toLowerCase())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return UserModel.fromMap(data);
    }
    return null;
  }

  Future<UserModel?> fetchUserByUid(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<UserModel?> fetchUserByUsername(String username) async {
    final doc = await _firestore.collection('users').doc(username).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final doc = await _firestore
        .collection('users')
        .doc(username.trim().toLowerCase())
        .get();
    return doc.exists;
  }

  Future<bool> saveUserData({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(docId).set(data);
      return true;
    } catch (e) {
      print("Error saving user data: $e");
      return false;
    }
  }

  Future<bool> updateUserData({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(docId).update(data);
      return true;
    } catch (e) {
      print("Error updating user data: $e");
      return false;
    }
  }

  Future<void> setPrefLoginStatus(bool loginStatus) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("isLoggedIn", loginStatus);
  }

  Future<bool> getPrefLoginStatus() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool("isLoggedIn") ?? false;
  }
}
