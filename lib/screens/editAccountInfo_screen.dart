import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAccountInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditAccountInfoScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditAccountInfoScreen> createState() => _EditAccountInfoScreenState();
}

class _EditAccountInfoScreenState extends State<EditAccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String? _gender;
  List<String> selectedDomains = [];
  List<String> selectedLanguages = [];

  final List<String> allDomains = [
    "Cybersecurity",
    "Blockchain & Web3",
    "Data Science & Analytics",
    "Game Development",
    "AI/ML",
    "Cloud Computing",
  ];

  final List<String> allLanguages = ["C", "C++", "Python", "Java", "Dart", "JavaScript"];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData["Username"]);
    _bioController = TextEditingController(text: widget.userData["Bio"]);
    _emailController = TextEditingController(text: widget.userData["Email"]);
    _phoneController = TextEditingController(text: widget.userData["Phone"]);
    _dobController = TextEditingController(text: widget.userData["dob"]);
    _gender = widget.userData["Gender"];
    selectedDomains = List<String>.from(widget.userData["Domains"] ?? []);
    selectedLanguages = List<String>.from(widget.userData["Languages"] ?? []);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "Username": _usernameController.text.trim(),
        "Bio": _bioController.text.trim(),
        "Email": _emailController.text.trim(),
        "Phone": _phoneController.text.trim(),
        "dob": _dobController.text.trim(),
        "Gender": _gender,
        "Domains": selectedDomains,
        "Languages": selectedLanguages,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField("Username", _usernameController),
              _textField("Bio", _bioController, maxLines: 3),
              _textField("Email", _emailController),
              _textField("Phone", _phoneController),
              _textField("DOB", _dobController),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              const SizedBox(height: 16),
              _multiSelect("Domains", allDomains, selectedDomains),
              const SizedBox(height: 16),
              _multiSelect("Languages", allLanguages, selectedLanguages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _multiSelect(String label, List<String> allOptions, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: allOptions.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
