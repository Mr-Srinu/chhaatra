import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

final homePostsRepositoryProvider = Provider<HomePostsRepository>((ref) {
  return HomePostsRepository(firestore: FirebaseFirestore.instance);
});

class HomePostsRepository {
  final FirebaseFirestore _firestore;

  HomePostsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<QuerySnapshot> fetchInitialPosts({int limit = 6}) async {
    return await _firestore
        .collection('posts')
        .orderBy('time', descending: true)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot> fetchMorePosts({
    required DocumentSnapshot lastDoc,
    int limit = 6,
  }) async {
    return await _firestore
        .collection('posts')
        .orderBy('time', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
  }

  Future<bool> checkUserLiked(String postId, String userId) async {
    final likeDoc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedby')
        .doc(userId)
        .get();
    return likeDoc.exists;
  }

  Future<void> addLike(String postId, String userId, String username) async {
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedby')
        .doc(userId);

    await likeRef.set({
      'userId': userId,
      'likedAt': FieldValue.serverTimestamp(),
      'username': username,
    });

    await _firestore
        .collection('posts')
        .doc(postId)
        .update({'likes': FieldValue.increment(1)});
  }

  Future<void> removeLike(String postId, String userId) async {
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedby')
        .doc(userId);

    await likeRef.delete();

    await _firestore
        .collection('posts')
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});
  }

  Future<void> sharePost(Map<String, dynamic> post) async {
    try {
      final response = await http.get(Uri.parse(
          "https://cdn.jsdelivr.net/gh/bsv15/my_flutter_app@main/Share_Ref/share_new.txt"));
      if (response.statusCode == 200) {
        String template = response.body;
        String username = post['username'] ?? "";
        String desc =
            (post['description'] ?? "").toString().split('\n').first.trim();
        String shareText = template
            .replaceAll('{{username}}', username)
            .replaceAll('{{description}}', desc)
            .replaceAll('{{link}}', 'www.google.com');

        Share.share(shareText, subject: "Chhaatra APP, Download Now");
      }
    } catch (e) {
      print("Error sharing post: $e");
    }
  }
}
