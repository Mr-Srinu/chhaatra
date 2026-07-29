import 'dart:async';
import 'package:chhaatra/materials/image_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../materials/usermodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    ImageService.service = ImageService();
    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Run login check after splash delay
    Future.delayed(const Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  Future<void> setPref({loginStatus = false}) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("isLoggedIn", loginStatus);
  }

  Future<bool> getPref() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey("isLoggedIn")) {
      final isLoggin = (pref.getBool("isLoggedIn"))!;
      return isLoggin;
    } else {
      setPref(loginStatus: false);
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    final authUser = FirebaseAuth.instance.currentUser;
    // final loginStatus = await getPref();'
    final loginStatus = await getPref();
    try {
      if (authUser != null) {
        if (loginStatus) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(authUser.uid)
                .get();

            if (doc.exists) {
              UserModel.currentUser = UserModel.fromMap(doc.data()!);
              await setPref(loginStatus: true);
              await ImageService.service?.loadImage(UserModel.currentUser?.userName ?? "default");
              Fluttertoast.showToast(
                msg: "Welcome back, ${UserModel.currentUser!.userName}",
                backgroundColor: AppColors.textPrimary,
                timeInSecForIosWeb: 4,
                fontSize: 14,
                textColor: AppColors.bg,
              );

              if (mounted) {
                UserModel.loadPrefs();
                Navigator.pushReplacementNamed(context, '/home');
              }
              return;
            }
          } catch (e) {
            Fluttertoast.showToast(
              msg: "Error loading user data. Try again.",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        } else {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      }
    } catch (e) {
      print(e.toString());
      Navigator.pushReplacementNamed(context, '/signin');
    }

    // fallback if not logged in or error
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg2,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CachedNetworkImage(
            //   imageUrl: "https://imgs.search.brave.com/FHwrQub8fSHe3rdKGvO67XPU_hpcrpy69J6pDozcjpU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/ZHJpYmJibGUuY29t/L3VzZXJ1cGxvYWQv/MjI4ODU2MTkvZmls/ZS9vcmlnaW5hbC0y/OWZkOGU3ZDc4ZGYy/MzRiZjM1NzU2ZmM3/ZDk3MTU2Ni5wbmc_/cmVzaXplPTQwMHgw",
            //   height: 120,
            //   width: 120,
            //   fit: BoxFit.cover,
            // ),
            ScaleTransition(
              scale: _animation,
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/images/logo3.png',
                  width: MediaQuery.of(context).size.width * 0.65,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // const SizedBox(height: 20),
            // Text(
            //   "Chhaatra",
            //   style: TextStyle(
            //     color: AppColors.textPrimary,
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
