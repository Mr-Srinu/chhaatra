import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String name;
  final String email;
  final String pass;
  final String uid;

  const VerifyPhoneScreen({
    super.key,
    required this.name,
    required this.email,
    required this.pass,
    required this.uid,
  });

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  ImagePicker picker = ImagePicker();
  late XFile file;

  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  var detailsKey = GlobalKey<FormState>();

  final List<String> genders = ['Male', 'Female', 'Others'];
  String? selectedGender;

  final List<String> languages = [
    'C',
    'C++',
    'Python',
    'Java',
    'HTML',
    'CSS',
    'JavaScript',
    'Dart',
    'Shell Scripting'
  ];
  List<String> intrestedLangs = [];

  final List<String> tech_domains = [
    "Artificial Intelligence (AI)",
    "Blockchain & Web3",
    "Cloud Computing",
    "Cybersecurity",
    "Data Science & Analytics",
    "DevOps & SRE",
    "Game Development",
    "Internet of Things (IoT)",
    "Machine Learning & AI",
    "Mobile App Development",
    "Quantum Computing",
    "UI/UX Design",
    "Web Development"
  ];
  List<String> selectedDomains = [];

  var highlight = AppColors.textPrimary;

  Future<bool> insertData() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.saveUserData(
        docId: widget.name,
        data: {
          'Username': widget.name,
          'Email': widget.email,
          'Pass': widget.pass,
          'Profile': "",
          'Phone': phoneController.text,
          'Bio': bioController.text,
          'Gender': selectedGender,
          'Languages': intrestedLangs,
          'Domains': selectedDomains,
          'Solved': 0,
          'Replied': 0,
          'Posted': 0,
          'Posts': [],
          'Submissions': [],
          'XP': 0,
          'uid': widget.uid,
          'createdAt': Timestamp.now(),
        },
      );
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: detailsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "User Details",
                style: TextStyle(
                  fontSize: 38,
                  color: AppColors.textPrimary.withAlpha(220),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Please co-operate with us to make your experience better",
                style: TextStyle(fontSize: 13, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Avatar picker
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.bg2,
                    backgroundImage: const CachedNetworkImageProvider(
                      "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.photo_camera,
                        size: 20, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Bio
              _buildTextField(
                controller: bioController,
                label: "Bio",
                hint: "Describe about yourself...",
                icon: null,
              ),

              // Phone
              _buildTextField(
                controller: phoneController,
                label: "Phone",
                hint: "Enter your phone number",
                icon: Icons.phone,
                maxLength: 10,
                keyboard: TextInputType.number,
                counterText: "${phoneController.text.length}/10",
              ),

              // Date of birth
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: InkWell(
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
                    child: const Icon(Icons.calendar_month_outlined),
                  ),
                  label: const Text("Date of Birth"),
                  hintText: "DD/MM/YYYY",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17)
                        .copyWith(topLeft: Radius.zero),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: highlight,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(11)
                        .copyWith(topLeft: Radius.zero),
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),

              // Gender
              DropdownButtonFormField(
                value: selectedGender,
                decoration: InputDecoration(
                  label: const Text("Gender"),
                  hintText: "Select",
                  prefixIcon: Icon(
                    selectedGender == null
                        ? Icons.diversity_2_outlined
                        : selectedGender == 'Male'
                            ? Icons.male_outlined
                            : Icons.female_outlined,
                    color: selectedGender == null
                        ? Colors.yellow
                        : selectedGender == 'Male'
                            ? Colors.blue
                            : Colors.pink,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17)
                        .copyWith(topLeft: Radius.zero),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: highlight,
                      width: 2,
                    ),
                  ),
                ),
                items: genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedGender = value as String?),
                validator: (value) =>
                    value == null ? "Please select your gender" : null,
              ),
              const SizedBox(height: 20),

              // Languages
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Your Favourite Languages",
                  style: TextStyle(fontSize: 18, color: Colors.lightGreen),
                ),
              ),
              _buildCheckboxList(languages, intrestedLangs),

              const SizedBox(height: 20),

              // Domains
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Your Interested Domains",
                  style: TextStyle(fontSize: 18, color: Colors.lightGreen),
                ),
              ),
              _buildCheckboxList(tech_domains, selectedDomains),

              const SizedBox(height: 25),

              // Finish Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final isValid =
                        detailsKey.currentState?.validate() ?? false;
                    if (isValid) {
                      if (!context.mounted) return;
                      var inserted = await insertData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            inserted
                                ? "Account Created Successfully"
                                : "Something Wrong!, Please Try Again",
                            style: const TextStyle(
                              color: AppColors.bg,
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.textPrimary,
                        ),
                      );
                      if (inserted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/signin', ModalRoute.withName('/'));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary.withAlpha(220),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Finish",
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int? maxLength,
    TextInputType? keyboard,
    String? counterText,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboard ?? TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon) : null,
            label: Text(label),
            hintText: hint,
            counterText: counterText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17)
                  .copyWith(topLeft: Radius.zero),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: highlight,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(11)
                  .copyWith(topLeft: Radius.zero),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCheckboxList(List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: selectedList.contains(option),
              onChanged: (bool? isChecked) {
                if (isChecked == true) {
                  selectedList.add(option);
                } else {
                  selectedList.remove(option);
                }
              },
              activeColor: highlight,
            ),
            Text(option),
          ],
        );
      }).toList(),
    );
  }
}
