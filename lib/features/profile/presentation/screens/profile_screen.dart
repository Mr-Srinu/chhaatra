import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/domain/usermodel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'accountInfo_screen.dart';
import 'feedback_screen.dart';
import 'userPosts_screen.dart';
import 'userSettings_screen.dart';
import 'userSubmissions_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.bg;
    const textColor = Colors.white;
    final user = ref.watch(currentUserProvider) ?? UserModel.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: const Text('Profile', style: TextStyle(color: textColor)),
        ),
        body: const Center(
          child: Text("Please login to view profile",
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

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
                  backgroundImage: ImageService.service?.imageBytes != null
                      ? MemoryImage(ImageService.service!.imageBytes!)
                      : (user.profile.isNotEmpty
                          ? NetworkImage(user.profile)
                          : const NetworkImage(
                              'https://i.ibb.co/YTjW3vF/user-avatar.png'))
                          as ImageProvider,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.userName,
              style: const TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.bio,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, wordSpacing: 1.4),
            ),
            const SizedBox(height: 24),

            // Glowing Stats
            _GlowCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBlock(
                      label: 'Posts', value: user.posted.toString()),
                  _StatBlock(
                      label: 'Solved', value: user.solved.toString()),
                  _StatBlock(label: 'XP', value: user.xp.toString()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Options
            const _OptionTile(icon: Icons.leaderboard, label: 'Posts'),
            const _OptionTile(icon: Icons.bookmark, label: 'Account Info'),
            const _OptionTile(
                icon: Icons.terminal, label: 'My Submissions'),
            const _OptionTile(icon: Icons.settings, label: 'Settings'),
            const _OptionTile(
                icon: Icons.local_police_outlined, label: "Contribute"),
            const _OptionTile(
                icon: Icons.logout, label: 'Logout', isLogout: true),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6617DCF4),
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

class _OptionTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final bool isLogout;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      child: const Text(
                        "No",
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await UserModel.clearPrefs();
                        ref.read(currentUserProvider.notifier).setUser(null);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/signin', ModalRoute.withName('/'));
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 13),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            switch (label) {
              case "Posts":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserPostsScreen()),
                );
                break;
              case "Account Info":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccountInfoScreen()),
                );
                break;
              case "My Submissions":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserSubmissionsScreen()),
                );
                break;
              case "Settings":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserSettingsScreen()),
                );
                break;
              case "Contribute":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FeedbackScreen()),
                );
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

// Compatibility alias
typedef Profile = ProfileScreen;
