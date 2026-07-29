import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserSubmissionsScreen extends StatelessWidget {
  const UserSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text("My Submissions", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("submissions")
            .where("uid", isEqualTo: UserModel.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No submissions yet.", style: TextStyle(color: Colors.white54)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['problemTitle'] ?? "Problem",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  subtitle: Text("Status: ${data['status'] ?? "Pending"}",
                      style: const TextStyle(color: Colors.white54)),
                  trailing: Text(
                    data['language'] ?? "",
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
