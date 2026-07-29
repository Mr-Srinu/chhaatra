import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chhaatra/materials/image_service.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../materials/app_colors.dart';
import '../materials/userData.dart';
import 'languageSelection_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserData model;
  const UserDetailsScreen({super.key, required this.model });

  @override
  _UserDetailsScreen createState() => _UserDetailsScreen();
}

class _UserDetailsScreen extends State<UserDetailsScreen> {

  TextEditingController bioController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  // TextEditingController bioController = TextEditingController();

  var highlight = AppColors.textPrimary.withAlpha(220);
  final List<String> genders = ['Male','Female','Others'];
  String? selectedGender;
  static XFile? pickedImage;
  late File imgFile;
  bool setLoading = false;

  Future<void> pickImage() async{
    final ImagePicker imagePicker = ImagePicker();
    final XFile? img = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = img;
    });
  }

  Future<bool> uploadImg(File image) async{
    setState(() {
      setLoading = true;
    });
    try {
      final data = await ImageService().uploadImage(
          image, widget.model.userName as String);
      if (data["success"]) {
        setState(() {
          setLoading = false;
        });
        widget.model.profile = data["rawUrl"];
        widget.model.profileDummy = pickedImage;
        return true;
      } else {
        setState(() {
          setLoading = false;
        });
        return false;
      }
    }
    catch(e){
      setState(() {
        setLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Center(child: Text("User Details", style: TextStyle(color: AppColors.textPrimary.withAlpha(220)))),
      ),
      body: setLoading
        ? Center(child: CircularProgressIndicator())
        :
        SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Please co-operate with us to make your experience better",
              style: TextStyle(fontSize: 13, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [

                CircleAvatar(
                  radius: 55,
                  backgroundImage: pickedImage == null
                      ? CachedNetworkImageProvider(
                          "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                        )
                      : FileImage(File(pickedImage!.path)),
                  backgroundColor: AppColors.bg2,
                ),
                InkWell(
                  onTap: () async{
                    await pickImage();
                    print(pickedImage!.path.toString());
                    imgFile = File(pickedImage!.path);
                  },
                  child: Icon(Icons.camera_alt),
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: AppColors.textPrimary.withAlpha(200),
                //     shape: BoxShape.circle,
                //   ),
                //   padding: const EdgeInsets.all(6),
                //   child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                // ),
              ],
            ),
            const SizedBox(height: 30),

            // Bio
            _buildField("Bio", "App Developer | Unique | Creative", bioController),
            const SizedBox(height: 20),

            // Phone
            _buildField("Phone", "Enter your phone number", phoneController,
                icon: Icons.phone, keyboardType: TextInputType.number,counter: 10),
            const SizedBox(height: 20),

            // Date of Birth
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                label: Text("Date of Birth"),
                hintText: "DD/MM/YYYY",
                prefixIcon: Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: highlight, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onTap: () async {
                var picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  firstDate: DateTime(1990),
                );
                if (picked != null) {
                  dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                }
              },
            ),
            const SizedBox(height: 20),

            // Gender
            DropdownButtonFormField(
              value: selectedGender,
              decoration: InputDecoration(
                label: Text("Gender"),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: highlight, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value){
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary.withAlpha(220),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if(bioController.text.length > 1 && phoneController.text.length ==10 && dateController.text.isNotEmpty && selectedGender!.isNotEmpty){
                    widget.model.bio = bioController.text;
                    widget.model.phone = phoneController.text;
                    widget.model.dob = bioController.text;
                    widget.model.gender = selectedGender ?? "Not Specified";
                    if(imgFile != null){
                      final isUploaded = await uploadImg(imgFile);
                      if(isUploaded){
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (_) => LanguageSelectionPage(model:widget.model)),
                                (route) => false
                        );
                      }else{
                        Fluttertoast.showToast(msg: "Can't Process image, Please re select");
                      }
                    }else{
                        widget.model.profile = "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg";
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (_) => LanguageSelectionPage(model:widget.model)),
                                (route) => false
                        );
                      }
                  }else{
                    Fluttertoast.showToast(
                        msg: "Invalid Details",
                        timeInSecForIosWeb: 3,
                        backgroundColor: AppColors.bg2,
                    );
                  }
                },
                child: Text("Next", style: TextStyle(color: AppColors.bg, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType,int? counter}) {
    return TextFormField(
      controller: controller,
      maxLength: counter,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        // counterText: counter!= null ? "${phoneController.text.length}/10" : null,
        // counterStyle: TextStyle(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highlight, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
