import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postsServiceProvider = Provider<PostsService>((ref) => PostsService());

class PostsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "posts";

  Stream<List<Map<String, dynamic>>> getPosts() {
    Query query = _firestore
        .collection(collectionName)
        .orderBy('time', descending: true)
        .limit(5);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map<Map<String, dynamic>>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Future<void> createPost({
    required String title,
    required String description,
    String? imageUrl,
    String? userId,
    String? userName,
    String? userImage,
  }) async {
    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl ?? '',
      'userId': userId ?? '',
      'userName': userName ?? '',
      'userImage': userImage ?? '',
      'likes': 0,
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'time': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> toggleLike(String postId, String userId) async {
    var doc = FirebaseFirestore.instance.collection('posts').doc(postId);
    var snapshot = await doc.get();
    var data = snapshot.data();
    if (data != null) {
      List likes = data['likes'] is List ? (data['likes'] as List) : [];
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      await doc.update({'likes': likes});
    }
  }

  static Future<void> addComment(String postId, String text,
      {String? userId, String? userName, String? userImage}) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'text': text,
      'userId': userId ?? '',
      'userName': userName ?? '',
      'userImage': userImage ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'commentCount': FieldValue.increment(1)});
  }
}
