import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';

class AddJobScreen extends ConsumerStatefulWidget {
  const AddJobScreen({super.key});

  @override
  ConsumerState<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends ConsumerState<AddJobScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final typeController = TextEditingController();
  final postedOnController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final benefitsController = TextEditingController();
  final salaryController = TextEditingController();
  final stipendController = TextEditingController();
  final durationController = TextEditingController();
  final skillsController = TextEditingController();
  final applyLinkController = TextEditingController();
  final interviewProcessController = TextEditingController();

  final TextEditingController _jsonController = TextEditingController();

  static const _templateJson = {
    "job_id": null,
    "title": "",
    "company": "",
    "location": null,
    "type": null,
    "posted_on": "",
    "end_date": "",
    "time_left": null,
    "description": null,
    "requirements": null,
    "benefits": null,
    "duration": null,
    "stipend": null,
    "salary": "",
    "apply_link": null,
    "interview_process": null,
    "skills_required": [],
    "roles": [
      {"role_title": null, "apply_link": null}
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    typeController.dispose();
    postedOnController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    benefitsController.dispose();
    salaryController.dispose();
    stipendController.dispose();
    durationController.dispose();
    skillsController.dispose();
    applyLinkController.dispose();
    interviewProcessController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.bg2,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.bg,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  Future<void> _postJobFromForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final postedOn = DateTime.tryParse(postedOnController.text.trim());
      DateTime? deadline = endDateController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(endDateController.text.trim());

      if (postedOn != null && deadline == null) {
        deadline = postedOn.add(const Duration(days: 15));
      }

      final jobData = {
        "title": titleController.text.trim(),
        "company": companyController.text.trim(),
        "salary": salaryController.text.trim(),
        "posted_on": postedOnController.text.trim(),
        "deadline": deadline?.toIso8601String().split("T").first,
        "skills_required": skillsController.text
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        "location": locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        "type": typeController.text.trim().isEmpty
            ? null
            : typeController.text.trim(),
        "description": descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        "requirements": requirementsController.text.trim().isEmpty
            ? null
            : requirementsController.text
                .split("\n")
                .where((e) => e.isNotEmpty)
                .toList(),
        "benefits": benefitsController.text.trim().isEmpty
            ? null
            : benefitsController.text
                .split("\n")
                .where((e) => e.isNotEmpty)
                .toList(),
        "duration": durationController.text.trim().isEmpty
            ? null
            : durationController.text.trim(),
        "stipend": stipendController.text.trim().isEmpty
            ? null
            : stipendController.text.trim(),
        "apply_link": applyLinkController.text.trim().isEmpty
            ? null
            : applyLinkController.text.trim(),
        "interview_process": interviewProcessController.text.trim().isEmpty
            ? null
            : interviewProcessController.text.trim(),
        "status": "Active",
      };

      final docRef = FirebaseFirestore.instance.collection("jobs").doc();
      await docRef.set({...jobData, "id": docRef.id});

      Fluttertoast.showToast(msg: "Job posted successfully");
      _clearForm();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error posting job: $e");
    }
  }

  Future<void> _postJobFromJson() async {
    if (_jsonController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter JSON data");
      return;
    }
    try {
      final Map<String, dynamic> data =
          jsonDecode(_jsonController.text.trim());

      if ((data["deadline"] == null || data["deadline"].toString().isEmpty) &&
          data["posted_on"] != null &&
          data["posted_on"].toString().isNotEmpty) {
        final postedOn = DateTime.tryParse(data["posted_on"]);
        if (postedOn != null) {
          data["deadline"] = postedOn
              .add(const Duration(days: 15))
              .toIso8601String()
              .split("T")
              .first;
        }
      }

      final docRef = FirebaseFirestore.instance.collection("jobs").doc();
      await docRef.set({...data, "id": docRef.id});
      Fluttertoast.showToast(msg: "Job posted successfully");
      _jsonController.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid JSON: $e");
    }
  }

  void _insertTemplate() {
    _jsonController.text =
        const JsonEncoder.withIndent("  ").convert(_templateJson);
  }

  void _clearForm() {
    titleController.clear();
    companyController.clear();
    locationController.clear();
    typeController.clear();
    postedOnController.clear();
    endDateController.clear();
    descriptionController.clear();
    requirementsController.clear();
    benefitsController.clear();
    salaryController.clear();
    stipendController.clear();
    durationController.clear();
    skillsController.clear();
    applyLinkController.clear();
    interviewProcessController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text("Add Job"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textPrimary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Form"),
            Tab(text: "JSON"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // FORM TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _inputField(titleController, "Job Title", required: true),
                  _inputField(companyController, "Company", required: true),
                  _inputField(locationController, "Location"),
                  _inputField(typeController, "Job Type (Full Time / Intern)"),
                  _dateInput(postedOnController, "Posted On", required: true),
                  _dateInput(endDateController, "Application End Date"),
                  _inputField(descriptionController, "Description",
                      maxLines: 3),
                  _inputField(requirementsController,
                      "Requirements (one per line)",
                      maxLines: 3),
                  _inputField(
                      benefitsController, "Benefits (one per line)",
                      maxLines: 2),
                  _inputField(durationController, "Duration"),
                  _inputField(stipendController, "Stipend"),
                  _inputField(salaryController, "Salary / PPO", required: true),
                  _inputField(skillsController,
                      "Skills (comma separated e.g. Dart, Flutter)",
                      required: true),
                  _inputField(applyLinkController, "Apply Link (URL)"),
                  _inputField(
                      interviewProcessController, "Interview Process",
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _actionButton("Post Job", _postJobFromForm),
                ],
              ),
            ),
          ),

          // JSON TAB
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _jsonController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                        fontFamily: "monospace",
                        fontSize: 13,
                        color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter or edit job JSON here...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.bg2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton("Template", _insertTemplate),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton("Post Job", _postJobFromJson),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? "Please enter $label"
                : null
            : null,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: AppColors.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateInput(TextEditingController ctrl, String label,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _pickDate(ctrl),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? "Please select $label"
                : null
            : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          filled: true,
          fillColor: AppColors.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}

// Compatibility alias
typedef AddJob = AddJobScreen;
