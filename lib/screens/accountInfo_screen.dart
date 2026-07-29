import 'package:flutter/material.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/usermodel.dart';

import '../materials/image_service.dart';
import 'editAccountInfo_screen.dart';
// import 'edit_account_info_screen.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserModel.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit, color: Colors.white),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => EditAccountInfoScreen(userData: user.toMap()),
        //         ),
        //       );
        //     },
        //   )
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage:ImageService.service?.imageBytes !=null ? MemoryImage(ImageService.service!.imageBytes!)
                  // : CachedNetworkImageProvider(UserModel.currentUser!.profile) ??
                      :  const NetworkImage('https://i.ibb.co/YTjW3vF/user-avatar.png'),
                  backgroundColor: Colors.grey.shade700,
                  child: user.profile.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user.userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                if (user.bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(user.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("XP", user.xp.toString()),
              _statBox("Solved", user.solved.toString()),
              _statBox("Posts", user.posted.toString()),
            ],
          ),
          const SizedBox(height: 24),

          // Info Section
          _infoCard("Profile Info", {
            "Email": user.email,
            "Phone": user.phone,
            "Gender": user.gender,
            "DOB": user.dob,
          }),

          if (user.domains.isNotEmpty)
            _chipSection("Interested Domains", user.domains),
          if (user.languages.isNotEmpty)
            _chipSection("Languages", user.languages),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _infoCard(String title, Map<String, String?> data) {
    return Card(
      color: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const Divider(color: Colors.white24),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text("${e.key}: ",
                      style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                  Expanded(
                      child: Text(e.value ?? "Not Provided",
                          style: const TextStyle(color: Colors.white))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _chipSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((e) => Chip(
              label: Text(e,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.bg2,
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
