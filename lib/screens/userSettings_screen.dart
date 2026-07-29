import 'package:chhaatra/materials/app_colors.dart';
import 'package:flutter/material.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
