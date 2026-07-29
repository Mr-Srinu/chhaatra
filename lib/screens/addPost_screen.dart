import 'package:cached_network_image/cached_network_image.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:showcaseview/showcaseview.dart';

import '../materials/image_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> with SingleTickerProviderStateMixin {

  String postType = "Post";
  late TabController tabController;
  final formKey = GlobalKey<FormState>();
  bool ifFormValid = false;
  TextEditingController content = TextEditingController();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    content.addListener( (){
        setState(() {});
      }
    );
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  Future<bool> submitPost() async{
    if(UserModel.currentUser != null && content.text.isNotEmpty){
      try{
        await FirebaseFirestore.instance.collection("posts").add(
            {
              "username" :  UserModel.currentUser!.userName,
              "uid" : UserModel.currentUser!.uid,
              "profile": UserModel.currentUser?.profile ?? "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
              "description" : content.text.toString(),
              "likes" : 0,
              "comments" :  0,
              "shares" : 0,
              "time" : FieldValue.serverTimestamp()
            }
        );
        await FirebaseFirestore.instance.collection('users')
            .doc(UserModel.currentUser!.userName).update({'Posted': FieldValue.increment(1)});
        UserModel.currentUser?.posted++;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Posted Successfully",
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,)),
              backgroundColor: Colors.green[600],
              duration: Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10)
              ),
            )
        );
        Navigator.pop(context);
        return true;
      }catch(e){
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
        title: Text("Post"),
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        // bottom: TabBar(
        //     controller: tabController,
        //     tabs: [
        //       Tab(text: "Post",),
        //       Tab(text: "Challenge",)
        //     ]),
      ),

      // body: TabBarView(
      //     controller: tabController,
      //     children: [PostWidget(), ChallengeWidget()]
      // )
      body: SingleChildScrollView(child: PostWidget()),
    );
  }

  Widget PostWidget(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(15,25, 15, 100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          // color: AppColors.textPrimary
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
                    padding: const EdgeInsets.fromLTRB(20,25, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: ImageService.service?.imageBytes !=null ? MemoryImage(ImageService.service!.imageBytes!)
                              // : CachedNetworkImageProvider(UserModel.currentUser!.profile) ??
                                  :  const NetworkImage('https://i.ibb.co/YTjW3vF/user-avatar.png'),
                            ),
                            SizedBox(width: 15,),
                            Text(UserModel.currentUser!.userName,style: TextStyle(color: AppColors.textPrimary,fontSize: 18,),),
                          ],
                        ),

                        TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states){
                                if(states.contains(WidgetState.disabled)){
                                  return Colors.white60;
                                }
                                else{
                                  return Colors.white;
                                }
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith<Color>((states){
                                if(states.contains(WidgetState.disabled)){
                                  return AppColors.bg;
                                }
                                else{
                                  return Colors.black87;
                                }
                              })
                            ),
                            onPressed: ()async{
                              final isTrue = await submitPost();
                              !isTrue & content.text.isNotEmpty ? null
                                  : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Posted Successfully",
                                          style: TextStyle(fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,)),
                                      backgroundColor: Colors.green[600],
                                      duration: Duration(seconds: 3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10)
                                      ),
                                    )
                                );
                                Navigator.pop(context);
                              };
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                              child: Text("Post",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,letterSpacing: 1),),
                            ))
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 25),
                    child: TextFormField(
                      controller: content,
                      minLines: 10,
                      maxLines: 15,
                      decoration: InputDecoration(
                        hintText: "What's in Your Mind....",
                        border: InputBorder.none
                      ),
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }

  Widget ChallengeWidget(){
    return Form(
        child: Column(
          children: [
            Text("Title: "),
            TextFormField(
              minLines: 10,
              maxLines: 15,
              decoration: InputDecoration(
                  hintText: "Throw a Challenge",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
            )
          ],
        )
    );
  }
}
