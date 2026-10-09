import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_repository.dart';

final userSubmissionsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserSubmissionsStream(uid);
});

final userPostsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserPostsStream(uid);
});

final userReportsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserReportsStream(uid);
});
