import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/posts_service.dart';

final postsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(postsServiceProvider);
  return service.getPosts();
});

final commentsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('commentedby')
      .orderBy("commentedAt", descending: true)
      .snapshots();
});
