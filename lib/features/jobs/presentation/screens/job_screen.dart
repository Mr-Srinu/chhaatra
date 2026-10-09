import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import 'addJob_screen.dart';
import 'jobDetails_screen.dart';

class JobScreen extends ConsumerWidget {
  const JobScreen({super.key});

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildLabelValue(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(color: Colors.blue[200]),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>? ?? {};

              final title = job['title'] ?? '';
              final company = job['company'] ?? '';
              final duration = job['duration'] ?? '';
              final stipend = job['stipend'] ?? '';
              final ppo = job['salary'] ?? '';
              final location = job['location'] ?? '';
              final applyUrl = job['apply_link'] ?? '';

              final roles = (job['roles'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [];

              return Card(
                color: AppColors.bg2,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobDetailsScreen(jobData: job),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // JOB TITLE + COMPANY (top highlight)
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (company.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Key Offer Info
                        Row(
                          children: [
                            if (duration.isNotEmpty)
                              Expanded(
                                  child:
                                      _buildLabelValue("Duration", duration)),
                            if (stipend.isNotEmpty)
                              Expanded(
                                  child:
                                      _buildLabelValue("Stipend", stipend)),
                          ],
                        ),
                        if (ppo.isNotEmpty) _buildLabelValue("Salary ", ppo),
                        if (location.isNotEmpty)
                          _buildLabelValue("Location", location),

                        const SizedBox(height: 16),

                        // APPLY NOW button
                        if (applyUrl.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _launchURL(applyUrl),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blueAccent.withAlpha(210),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "Apply Now",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),

                        // Roles
                        if (roles.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            "Other Roles:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: roles.map((role) {
                              final roleTitle =
                                  role['role_title'] ?? 'No Role Name';
                              final roleUrl = role['apply_link'] ?? '';
                              return OutlinedButton(
                                onPressed: roleUrl.isNotEmpty
                                    ? () => _launchURL(roleUrl)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.blueAccent),
                                ),
                                child: Text(
                                  roleTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
        },
        child: const Icon(Icons.add_box),
      ),
    );
  }
}

// Compatibility alias
typedef Jobs = JobScreen;
