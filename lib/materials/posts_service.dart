
import 'package:cloud_firestore/cloud_firestore.dart';

class PostsService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "posts";

  Stream<List<Map<String, dynamic>>> getPosts(){
    Query query = _firestore
        .collection(collectionName)
        .orderBy('time',descending: true)
        .limit(5);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map<Map<String,dynamic>>((doc) {
        final data = doc.data() as Map<String,dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

}
