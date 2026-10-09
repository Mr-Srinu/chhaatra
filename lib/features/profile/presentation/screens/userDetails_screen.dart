import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/domain/userData.dart';
import '../../../onboarding/presentation/screens/languageSelection_screen.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final UserData model;
  const UserDetailsScreen({super.key, required this.model});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  TextEditingController bioController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  var highlight = AppColors.textPrimary.withAlpha(220);
  final List<String> genders = ['Male', 'Female', 'Others'];
  String? selectedGender;
  static XFile? pickedImage;
  File? imgFile;
  bool setLoading = false;

  Future<void> pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? img =
        await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = img;
    });
  }

  Future<bool> uploadImg(File image) async {
    setState(() {
      setLoading = true;
    });
    try {
      final data = await ImageService().uploadImage(
          image, (widget.model.userName ?? "default").toString());
      if (data["success"] == true) {
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
    } catch (e) {
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
        title: Center(
          child: Text(
            "User Details",
            style: TextStyle(color: AppColors.textPrimary.withAlpha(220)),
          ),
        ),
      ),
      body: setLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
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
                            ? const CachedNetworkImageProvider(
                                "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                              )
                            : FileImage(File(pickedImage!.path))
                                as ImageProvider,
                        backgroundColor: AppColors.bg2,
                      ),
                      InkWell(
                        onTap: () async {
                          await pickImage();
                          if (pickedImage != null) {
                            imgFile = File(pickedImage!.path);
                          }
                        },
                        child: const Icon(Icons.camera_alt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Bio
                  _buildField("Bio", "App Developer | Unique | Creative",
                      bioController),
                  const SizedBox(height: 20),

                  // Phone
                  _buildField("Phone", "Enter your phone number",
                      phoneController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                      counter: 10),
                  const SizedBox(height: 20),

                  // Date of Birth
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      label: const Text("Date of Birth"),
                      hintText: "DD/MM/YYYY",
                      prefixIcon:
                          const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
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
                        dateController.text =
                            DateFormat('dd/MM/yyyy').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  DropdownButtonFormField(
                    value: selectedGender,
                    decoration: InputDecoration(
                      label: const Text("Gender"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: highlight, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: genders
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (value) {
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
                        if (bioController.text.length > 1 &&
                            phoneController.text.length == 10 &&
                            dateController.text.isNotEmpty &&
                            selectedGender != null &&
                            selectedGender!.isNotEmpty) {
                          widget.model.bio = bioController.text;
                          widget.model.phone = phoneController.text;
                          widget.model.dob = dateController.text;
                          widget.model.gender =
                              selectedGender ?? "Not Specified";
                          if (imgFile != null) {
                            final isUploaded = await uploadImg(imgFile!);
                            if (isUploaded && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LanguageSelectionPage(
                                      model: widget.model),
                                ),
                                (route) => false,
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Can't Process image, Please re select");
                            }
                          } else {
                            widget.model.profile =
                                "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg";
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LanguageSelectionPage(
                                      model: widget.model),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "Invalid Details",
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppColors.bg2,
                          );
                        }
                      },
                      child: const Text("Next",
                          style: TextStyle(color: AppColors.bg, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType, int? counter}) {
    return TextFormField(
      controller: controller,
      maxLength: counter,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highlight, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

// Compatibility for viewing a user's details by UID
class UserDetails extends ConsumerStatefulWidget {
  final String uid;
  const UserDetails({super.key, required this.uid});

  @override
  ConsumerState<UserDetails> createState() => _UserDetailsViewOnlyState();
}

class _UserDetailsViewOnlyState extends ConsumerState<UserDetails> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(
                  child: Text("User not found",
                      style: TextStyle(color: Colors.white)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: userData!['Profile'] != null &&
                                userData!['Profile'].toString().isNotEmpty
                            ? CachedNetworkImageProvider(
                                userData!['Profile'])
                            : const AssetImage("assets/images/logo.jpg")
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        userData!['Username'] ?? userData!['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        userData!['Email'] ?? userData!['email'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
    );
  }
}
