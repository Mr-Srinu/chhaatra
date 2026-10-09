import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/jobs_repository.dart';

final jobsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  return repo.getJobsStream();
});
