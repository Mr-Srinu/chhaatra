import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/image_service.dart';
import 'package:chhaatra/materials/userData.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:chhaatra/screens/accountInfo_screen.dart';
import 'package:chhaatra/screens/feedback_screen.dart';
import 'package:chhaatra/screens/userDetails_screen.dart';
import 'package:chhaatra/screens/userPosts_screen.dart';
import 'package:chhaatra/screens/userSettings_screen.dart';
import 'package:chhaatra/screens/userSubmissions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if(UserModel.currentUser!.profile != null){
    //   getProfile();
    // }
  }


  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.bg; // Light background
    const cardColor = AppColors.bg2;
    const accentColor = AppColors.textPrimary; // Neon cyan
    const textColor = Colors.white; // Rich dark text

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          ' Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 52.3,
                  backgroundColor: AppColors.textPrimary,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: ImageService.service?.imageBytes !=null ? MemoryImage(ImageService.service!.imageBytes!)
                   // : CachedNetworkImageProvider(UserModel.currentUser!.profile) ??
                    :  const NetworkImage('https://i.ibb.co/YTjW3vF/user-avatar.png'),
                ),
              ]
            ),
            const SizedBox(height: 12),
            Text(
              UserModel.currentUser!.userName,
              style: const TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              UserModel.currentUser!.bio,
              style: TextStyle(color: Colors.white70, fontSize: 14,wordSpacing: 1.4),
            ),
            const SizedBox(height: 24),

            // Glowing Stats
            _GlowCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBlock(label: 'Posts', value: UserModel.currentUser!.posted.toString()),
                  _StatBlock(label: 'Solved', value: UserModel.currentUser!.solved.toString()),
                  _StatBlock(label: 'XP', value: UserModel.currentUser!.xp.toString()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Options
            _OptionTile(icon: Icons.leaderboard, label: 'Posts', ),
            _OptionTile(icon: Icons.bookmark, label: 'Account Info'),
            _OptionTile(icon: Icons.terminal, label: 'My Submissions'),
            _OptionTile(icon: Icons.settings, label: 'Settings'),
            _OptionTile(icon: Icons.local_police_outlined, label: "Contribute"),
            _OptionTile(icon: Icons.logout, label: 'Logout', isLogout: true),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}

class _GlowCard extends StatelessWidget {
  final Widget child;

  const _GlowCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        // color: AppColors.bg2,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6617DCF4), // Cyan glow
            blurRadius: 2.2,
            spreadRadius: 0.4,
            offset: Offset(0, 1),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLogout;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.bg2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        onTap: () async {
          if (isLogout) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Do you really want to logout?"),
                  backgroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No",
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await UserModel.clearPrefs();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/signin', ModalRoute.withName('/'));
                      },
                      child: const Text("Yes",
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                              fontSize: 13)),
                    ),
                  ],
                );
              },
            );
          } else {
            switch (label) {
              case "Posts":
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UserPostsScreen()));
                break;
              case "Account Info":
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AccountInfoScreen()));
                break;
              case "My Submissions":
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserSubmissionsScreen()));
                break;
              case "Settings":
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserSettingsScreen()));
                break;
              case "Contribute":
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FeedbackScreen()));
                break;
              default:
                debugPrint("Unknown option tapped: $label");
            }
          }
        },
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.redAccent : AppColors.textPrimary,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isLogout ? Colors.redAccent : Colors.white,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: isLogout ? Colors.redAccent : Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

