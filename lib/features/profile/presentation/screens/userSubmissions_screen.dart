import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/usermodel.dart';

class UserSubmissionsScreen extends ConsumerWidget {
  const UserSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid =
        UserModel.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text("My Submissions", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(
              child: Text("Please log in to view submissions.",
                  style: TextStyle(color: Colors.white54)),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("submissions")
                  .where("uid", isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No submissions yet.",
                        style: TextStyle(color: Colors.white54)),
                  );
                }
                final subs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: subs.length,
                  itemBuilder: (context, i) {
                    final data = subs[i].data() as Map<String, dynamic>;
                    return Card(
                      color: AppColors.bg2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          data['problemTitle'] ?? "Problem",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "Status: ${data['status'] ?? "Pending"}",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          data['language'] ?? "",
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Compatibility alias
typedef UserSubmissions = UserSubmissionsScreen;
