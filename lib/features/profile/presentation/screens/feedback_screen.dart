import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();

  String _type = "Feedback";
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _screenshotController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _screenshotController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection("user_reports").add({
        "type": _type,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "screenshotUrl": _screenshotController.text.trim(),
        "userId": user?.uid ?? "guest",
        "userName": user?.displayName,
        "status": "Pending",
        "reply": "",
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report submitted successfully ")),
        );
      }

      _titleController.clear();
      _descController.clear();
      _screenshotController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSubmitTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: "Feedback", child: Text("Feedback")),
                  DropdownMenuItem(
                      value: "Complaint", child: Text("Complaint")),
                  DropdownMenuItem(
                      value: "Bug Report", child: Text("Bug Report")),
                ],
                onChanged: (val) {
                  setState(() {
                    _type = val!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(190)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                validator: (val) => val!.isEmpty ? "Enter a title" : null,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(190)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                validator: (val) => val!.isEmpty ? "Enter description" : null,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(190)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _screenshotController,
                decoration: InputDecoration(
                  labelText: "Screenshot URL (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(190)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary.withAlpha(150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitFeedback,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bg,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyReportsTab() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Please log in to view your reports."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("user_reports")
          .where("userId", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading reports"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return const Center(child: Text("No reports found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.bg2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(report["title"] ?? ""),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${report["type"]}"),
                    const SizedBox(height: 4),
                    Text(
                      "Status: ${report["status"] ?? "Pending"}",
                      style: TextStyle(
                        color: report["status"] == "Resolved"
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((report["reply"] ?? "").isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text("Reply: ${report["reply"]}"),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Feedback & Reports"),
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          labelColor: Colors.white,
          indicatorColor: AppColors.textPrimary,
          controller: _tabController,
          tabs: const [
            Tab(text: "Submit"),
            Tab(text: "My Reports"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitTab(),
          _buildMyReportsTab(),
        ],
      ),
    );
  }
}

// Compatibility alias
typedef FeedBack = FeedbackScreen;
