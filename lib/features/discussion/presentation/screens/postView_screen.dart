import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/usermodel.dart';

class PostViewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> postData;

  const PostViewScreen({super.key, required this.postData});

  @override
  ConsumerState<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends ConsumerState<PostViewScreen> {
  TextEditingController commentController = TextEditingController();

  String formatTime(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} month ago';
    return '${(diff.inDays / 365).floor()} year ago';
  }

  Future<void> addComment(String postId, String comment) async {
    final user = UserModel.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('commentedby')
        .doc("${user.uid}_${DateTime.now().millisecondsSinceEpoch}")
        .set({
      "userId": user.uid,
      "username": user.userName,
      "content": comment,
      "profile": user.profile.isNotEmpty
          ? user.profile
          : "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
      "commentedAt": FieldValue.serverTimestamp(),
    });

    // Increment comment count in post
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      "comments": FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postData;
    final timestamp = post['time'] as Timestamp?;
    final convertedDate = timestamp?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          /// Post details
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.bg2,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundImage: CachedNetworkImageProvider(
                          post["profile"] ??
                              "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            convertedDate != null
                                ? formatTime(convertedDate)
                                : "",
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
                  // Post description
                  Text(
                    post['description'] ?? "",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Action row
                  Row(
                    children: [
                      const Icon(Icons.favorite_border,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text((post['likes'] ?? 0).toString()),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment_outlined,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text((post['comments'] ?? 0).toString()),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          final response = await http.get(Uri.parse(
                              "https://cdn.jsdelivr.net/gh/bsv15/my_flutter_app@main/Share_Ref/share_new.txt"));
                          if (response.statusCode == 200) {
                            String template = response.body;
                            String username = post['username'] ?? "";
                            String desc = (post['description'] ?? "")
                                .toString()
                                .split('\n')
                                .first
                                .trim();
                            String shareText = template
                                .replaceAll('{{username}}', username)
                                .replaceAll('{{description}}', desc)
                                .replaceAll('{{link}}', 'www.google.com');
                            Share.share(shareText,
                                subject: "Chhaatra APP, Download Now");
                          }
                        },
                        child: const Icon(Icons.share_outlined,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Comments section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(post['id'])
                  .collection('commentedby')
                  .orderBy("commentedAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                final comments = snapshot.data!.docs;

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade700),
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    final ts = comment['commentedAt'] as Timestamp?;
                    final time = ts?.toDate();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        backgroundImage: CachedNetworkImageProvider(
                          comment["profile"] ??
                              "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                        ),
                      ),
                      title: Text(
                        comment['username'] ?? "Unknown",
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        comment['content'] ?? "",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        time != null ? formatTime(time) : "",
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.bg,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      addComment(post['id'], commentController.text.trim());
                      commentController.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: AppColors.textPrimary),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Compatibility wrapper for string postId
class PostView extends ConsumerWidget {
  final String postId;
  const PostView({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('posts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        data['id'] = postId;
        return PostViewScreen(postData: data);
      },
    );
  }
}
