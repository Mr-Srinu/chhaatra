import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/domain/usermodel.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen>
    with SingleTickerProviderStateMixin {
  String postType = "Post";
  late TabController tabController;
  final formKey = GlobalKey<FormState>();
  bool ifFormValid = false;
  TextEditingController content = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    content.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    content.dispose();
    super.dispose();
  }

  Future<bool> submitPost() async {
    if (UserModel.currentUser != null && content.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection("posts").add({
          "username": UserModel.currentUser!.userName,
          "uid": UserModel.currentUser!.uid,
          "profile": UserModel.currentUser?.profile.isNotEmpty == true
              ? UserModel.currentUser!.profile
              : "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
          "description": content.text.toString(),
          "likes": 0,
          "comments": 0,
          "shares": 0,
          "time": FieldValue.serverTimestamp()
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserModel.currentUser!.userName)
            .update({'Posted': FieldValue.increment(1)});
        UserModel.currentUser?.posted++;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Posted Successfully",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
        return true;
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        return false;
      }
    }
    Fluttertoast.showToast(msg: "Please Check and Submit Once Again");
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(child: PostWidget()),
    );
  }

  Widget PostWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Card(
          borderOnForeground: true,
          color: AppColors.bg2,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: ImageService.service?.imageBytes !=
                                    null
                                ? MemoryImage(ImageService.service!.imageBytes!)
                                : const NetworkImage(
                                    'https://i.ibb.co/YTjW3vF/user-avatar.png'),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            UserModel.currentUser?.userName ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.white60;
                            } else {
                              return Colors.white;
                            }
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.bg;
                            } else {
                              return Colors.black87;
                            }
                          }),
                        ),
                        onPressed: () async {
                          await submitPost();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                          child: Text(
                            "Post",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 25),
                  child: TextFormField(
                    controller: content,
                    minLines: 10,
                    maxLines: 15,
                    decoration: const InputDecoration(
                      hintText: "What's in Your Mind....",
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ChallengeWidget() {
    return Form(
      child: Column(
        children: [
          const Text("Title: "),
          TextFormField(
            minLines: 10,
            maxLines: 15,
            decoration: InputDecoration(
              hintText: "Throw a Challenge",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Compatibility alias
typedef AddPost = AddPostScreen;
