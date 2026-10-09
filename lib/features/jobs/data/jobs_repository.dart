import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository(firestore: FirebaseFirestore.instance);
});

class JobsRepository {
  final FirebaseFirestore _firestore;

  JobsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getJobsStream() {
    return _firestore.collection('jobs').snapshots();
  }

  Future<void> postJob(Map<String, dynamic> jobData) async {
    final docRef = _firestore.collection("jobs").doc();
    await docRef.set({...jobData, "id": docRef.id});
  }

  Future<void> updateJobStatus(String jobId, String statusText) async {
    await _firestore
        .collection("jobs")
        .doc(jobId)
        .update({"status": statusText});
  }
}
