import 'package:cached_network_image/cached_network_image.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class UserPostsScreen extends StatelessWidget {
  const UserPostsScreen({super.key});

  String formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  Future<void> deletePosts(String postId) async{
    try{
      await FirebaseFirestore.instance.collection('posts')
          .doc(postId)
          .delete();
      await FirebaseFirestore.instance.collection('users')
          .doc(UserModel.currentUser!.userName)
          .update({'Posted': FieldValue.increment(-1)});
      UserModel.currentUser?.posted--;
    }catch(e){
      Fluttertoast.showToast(msg: "Something went wrong please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("My Posts", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection("posts")
                .where("uid", isEqualTo: UserModel.currentUser!.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No posts available"));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data();

              return Stack(
                alignment: Alignment.lerp(Alignment.topRight, Alignment.topLeft, 0.05)!,
                children: [
                  Card(
                    color: AppColors.bg2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundImage: CachedNetworkImageProvider(
                                  "https://raw.githubusercontent.com/bsv15/my_flutter_app/main/profile.jpeg",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['username'] ?? "Unknown",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTimestamp(post['time']),
                                    style: TextStyle(
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
                            style: TextStyle(fontSize: 16),
                          ),

                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 4),
                                  Text("${post["likes"] ?? 0} Likes"),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.comment_outlined, size: 20),
                                  SizedBox(width: 4),
                                  Text("${post["comments"] ?? 0} Comments"),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  // Implement share logic here
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AlertDialog(
                        content: Text("Do you really want to remove it? "),
                        actions: [
                          TextButton(onPressed: () {}, child: Text("No")),
                          TextButton(onPressed: () {}, child: Text("Yes")),
                        ],
                      );
                    },
                    child: Icon(Icons.delete, color: Colors.redAccent.withAlpha(190)),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}
