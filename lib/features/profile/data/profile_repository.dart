import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(firestore: FirebaseFirestore.instance);
});

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserSubmissionsStream(String uid) {
    return _firestore
        .collection("submissions")
        .where("uid", isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserPostsStream(String uid) {
    return _firestore
        .collection("posts")
        .where("uid", isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserReportsStream(String uid) {
    return _firestore
        .collection("user_reports")
        .where("userId", isEqualTo: uid)
        .snapshots();
  }

  Future<void> submitReport(Map<String, dynamic> reportData) async {
    await _firestore.collection("user_reports").add(reportData);
  }

  Future<void> deletePost(String postId, String username) async {
    await _firestore.collection('posts').doc(postId).delete();
    await _firestore
        .collection('users')
        .doc(username)
        .update({'Posted': FieldValue.increment(-1)});
  }
}
