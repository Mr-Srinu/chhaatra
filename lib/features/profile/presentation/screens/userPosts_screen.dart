import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/usermodel.dart';

class UserPostsScreen extends ConsumerWidget {
  const UserPostsScreen({super.key});

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  Future<void> deletePosts(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .delete();
      final username = UserModel.currentUser?.userName;
      if (username != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({'Posted': FieldValue.increment(-1)});
        UserModel.currentUser?.posted--;
      }
      Fluttertoast.showToast(msg: "Post deleted successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong please try again");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid =
        UserModel.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("My Posts", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(
              child: Text("Please login to see posts",
                  style: TextStyle(color: Colors.white54)),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("uid", isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No posts available",
                        style: TextStyle(color: Colors.white54)),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final postId = posts[index].id;

                    return Stack(
                      alignment: Alignment.lerp(
                          Alignment.topRight, Alignment.topLeft, 0.05)!,
                      children: [
                        Card(
                          color: AppColors.bg2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 23,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        "https://raw.githubusercontent.com/bsv15/my_flutter_app/main/profile.jpeg",
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['username'] ?? "Unknown",
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatTimestamp(
                                              post['time'] as Timestamp?),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post["description"] ?? "",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text("${post["likes"] ?? 0} Likes"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.comment_outlined,
                                            size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                            "${post["comments"] ?? 0} Comments"),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 20,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Post"),
                                  content: const Text(
                                      "Do you really want to remove it?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx),
                                        child: const Text("No")),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        deletePosts(context, postId);
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Icon(Icons.delete,
                                color: Colors.redAccent.withAlpha(190)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

// Compatibility alias
typedef UserPosts = UserPostsScreen;
