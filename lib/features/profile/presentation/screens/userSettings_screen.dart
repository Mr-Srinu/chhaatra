import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class UserSettingsScreen extends ConsumerWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            color: AppColors.bg2,
            child: ListTile(
              title: Text("Dark Mode", style: TextStyle(color: Colors.white)),
              trailing: Switch(value: true, onChanged: null),
            ),
          ),
          Card(
            color: AppColors.bg2,
            child: ListTile(
              title: Text("Notifications", style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white54, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Compatibility alias
typedef UserSettings = UserSettingsScreen;
