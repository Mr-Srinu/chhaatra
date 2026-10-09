import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/usermodel.dart';
import '../providers/auth_provider.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  var passwordVisible = true;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  Widget Box() {
    return const SizedBox();
  }

  Future<void> setPref({loginStatus = false}) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("isLoggedIn", loginStatus);
  }

  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passWordController.text.trim(),
      );

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Email', isEqualTo: emailController.text.trim().toLowerCase())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDetails = querySnapshot.docs.first.data();
        final user = UserModel.fromMap(userDetails);
        UserModel.currentUser = user;
        ref.read(currentUserProvider.notifier).setUser(user);
        await UserModel.savePrefs(user.userName, user.email);
        await ImageService.service
            ?.loadImage(UserModel.currentUser?.userName ?? "default");

        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Logged in as ${user.userName}",
          timeInSecForIosWeb: 6,
          backgroundColor: Colors.green,
          fontSize: 18,
          textColor: AppColors.bg,
          gravity: ToastGravity.TOP_RIGHT,
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/'));
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "No User Found, Please Verify Details",
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.redAccent,
          fontSize: 14,
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "Invalid Email/Password",
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.redAccent,
        fontSize: 14,
        gravity: ToastGravity.TOP,
      );
      print(e.message);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Title
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.withAlpha(220),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      /// Email
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          final bool checkEmail = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);
                          if (value.isEmpty || value.length < 3)
                            return "Enter Email";
                          if (!checkEmail) return "Enter Valid Email";
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Enter your email",
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppColors.textPrimary.withAlpha(180)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                                .copyWith(topLeft: Radius.zero),
                            borderSide: const BorderSide(color: Colors.white10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                                .copyWith(topLeft: Radius.zero),
                            borderSide: BorderSide(
                                color: AppColors.textPrimary.withAlpha(220),
                                width: 2),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: AppColors.textPrimary.withAlpha(220),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Password
                      TextFormField(
                        controller: passWordController,
                        validator: (value) {
                          final bool passValid = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                              .hasMatch(value!);
                          if (value.isEmpty || value.length < 8)
                            return "Invalid Password";
                          if (!passValid) return "Password is not strong";
                          return null;
                        },
                        obscureText: passwordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppColors.textPrimary.withAlpha(180)),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(
                                  () => passwordVisible = !passwordVisible);
                            },
                            child: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off_outlined,
                              color: Colors.white70,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                                .copyWith(topLeft: Radius.zero),
                            borderSide: const BorderSide(color: Colors.white10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                                .copyWith(topLeft: Radius.zero),
                            borderSide: BorderSide(
                                color: AppColors.textPrimary.withAlpha(150),
                                width: 2),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: AppColors.textPrimary.withAlpha(220),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (formKey.currentState!.validate()) {
                              signInWithEmailAndPassword();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            backgroundColor:
                                AppColors.textPrimary.withAlpha(220),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                                  .copyWith(topLeft: Radius.zero),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.bg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),

                      /// Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New User?",
                              style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/signup', ModalRoute.withName('/'));
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Colors.redAccent.withAlpha(200)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
