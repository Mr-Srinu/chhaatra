import 'dart:async';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobDetailsScreen({super.key, required this.jobData});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Timer _timer;
  DateTime? postedAt;
  DateTime? deadline;

  String statusText = "Active";
  Color statusColor = Colors.green;

  @override
  void initState() {
    super.initState();

    /// ✅ Convert Firestore Timestamp or String safely
    postedAt = _convertToDate(widget.jobData["posted_on"]);
    deadline = _convertToDate(widget.jobData["deadline"]);

    _updateStatus();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateStatus());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Helper to handle both Timestamp and String
  DateTime? _convertToDate(dynamic input) {
    if (input == null) return null;
    if (input is Timestamp) return input.toDate();
    if (input is DateTime) return input;
    if (input is String) return DateTime.tryParse(input);
    return null;
  }

  /// Format "time ago" or "remaining time"
  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (dateTime.isAfter(now)) {
      final remaining = dateTime.difference(now);
      if (remaining.inSeconds < 60) return 'In a few seconds';
      if (remaining.inMinutes < 60) return '${remaining.inMinutes} min remaining';
      if (remaining.inHours < 24) return '${remaining.inHours} hour${remaining.inHours > 1 ? 's' : ''} remaining';
      if (remaining.inDays < 7) return '${remaining.inDays} day${remaining.inDays > 1 ? 's' : ''} remaining';
      if (remaining.inDays < 30) return '${(remaining.inDays / 7).floor()} week remaining';
      return '${(remaining.inDays / 30).floor()} month remaining';
    }

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} month ago';
    return '${(diff.inDays / 365).floor()} year ago';
  }

  /// Update status and assign color
  void _updateStatus() {
    setState(() {
      if (deadline != null) {
        if (DateTime.now().isAfter(deadline!)) {
          statusText = "Closed";
          statusColor = Colors.redAccent;
        } else {
          final remaining = deadline!.difference(DateTime.now());
          if (remaining.inDays < 1) {
            statusText = "Closing Soon";
            statusColor = Colors.orangeAccent;
          } else {
            statusText = "Active";
            statusColor = Colors.green;
          }
        }
      } else {
        statusText = "Active";
        statusColor = Colors.green;
      }
      if (statusText != widget.jobData["status"]) {
        updateStatusOfJob(statusText);
      }
    });
  }
  Future<void> updateStatusOfJob(statusText) async {
      await FirebaseFirestore.instance
          .collection("jobs")
          .doc(widget.jobData["id"])  // uses stored docId
          .update({"status": statusText}); // only update 'status'
      widget.jobData["status"] = statusText;
}

  String cleanDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final stack = (widget.jobData['skills required'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];
    final applyUrl = widget.jobData['apply_link'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Job Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// STATUS BADGE
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  border: Border.all(color: statusColor, width: 1.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// MAIN CARD
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.black12,
              color: AppColors.bg2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      widget.jobData["title"] ?? "No Title",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// Company
                    if (widget.jobData["company"] != null)
                      Row(
                        children: [
                          const Icon(Icons.business,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.jobData["company"],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),

                    /// Location
                    if (widget.jobData["location"] != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on,
                              color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(widget.jobData["location"],
                                style: const TextStyle(
                                    fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),

                    /// Dates
                    const SizedBox(height: 12),

                    if (postedAt != null)
                      Text(
                        "📅 Posted: ${formatTime(postedAt!)} • ${cleanDate(postedAt!)}",
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),
                    if (deadline != null)
                      Text(
                        "⏳ Deadline: ${cleanDate(deadline!)}",
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),

                    /// Skills
                    if (stack.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text("Skills Required:",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: stack
                            .map((skill) => Chip(
                          label: Text(skill,
                              style: const TextStyle(fontSize: 13)),
                          backgroundColor:
                          Colors.blueAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ))
                            .toList(),
                      ),
                    ],

                    /// Dynamic Content
                    const SizedBox(height: 16),
                    ...widget.jobData.entries.map((entry) {
                      if ([
                        "title",
                        "company",
                        "skills required",
                        "apply_link",
                        "roles",
                        "status",
                        "postedAt",
                        "deadline"
                      ].contains(entry.key)) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent[200])),
                            Text(entry.value.toString(),
                                style: const TextStyle(
                                    fontSize: 15, wordSpacing: 1)),
                          ],
                        ),
                      );
                    }).toList(),

                    /// Apply Button
                    const SizedBox(height: 20),
                    if (widget.jobData["apply_link"] != null && widget.jobData['status'] != "Closed")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final uri = Uri.tryParse(applyUrl);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new,
                              color: Colors.white, size: 18),
                          label: const Text("Apply Now",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
