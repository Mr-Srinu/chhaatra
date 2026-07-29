import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/userData.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:chhaatra/screens/userDetails_screen.dart';
import 'package:chhaatra/screens/verifyPhone_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confPassController = TextEditingController();
  var regFormKey = GlobalKey<FormState>();
  bool pass = true;
  bool confpass = true;
  String excep = "";
  late String uid ;
  String _usernameError= "";
  bool _isCheckingUsername=false;
  bool isSignedUp = true;
  String hint_msg = "This will be displayed on the screen";

  var higlight =AppColors.textPrimary;
  late final model;
  @override
  void initState() {
    // TODO: implement initState
    model = UserData();
    super.initState();
  }
  Future<bool> signUpWithEmailAndPassword() async {
    setState(() {
      isSignedUp=false;
    });

    try{
      var isCreated = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
      );
      uid = isCreated.user!.uid;
      print(uid);
      setState(() {
        isSignedUp = true;
      });
      return true;
    }on FirebaseException catch(e){
      print(e.message);
      excep=e.message.toString();
      setState(() {
        isSignedUp = true;
      });
      return false;
    }
  }

  Future<void> validateUsername(user) async {
    setState(() {
      _isCheckingUsername = true;
      _usernameError = "";
    });

    final username = user.trim().toLowerCase();

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username is required';
        _isCheckingUsername = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (doc.exists) {
      setState(() {
        _usernameError = 'Username already taken';
        print("Username is already taken");
      });
    }
    setState(() {
      _isCheckingUsername = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: isSignedUp
          ? Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: regFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Title
                    Text(
                      "Sign Up.",
                      style: TextStyle(
                        fontSize: 38,
                        color: AppColors.textPrimary.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// Username
                    TextFormField(
                      controller: userNameController,
                      validator:(value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Username is required";
                        }
                        if (value.length < 3) {
                          return "Must be at least 3 characters";
                        }
                        return null; // only local checks
                      },
                      onChanged: (value) {
                        validateUsername(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.abc),
                        label: Text("Username"),
                        hintText: "Enter a username",
                        errorText: _usernameError.isNotEmpty ? _usernameError : null,
                        helperText: _usernameError.isEmpty && userNameController.text.isNotEmpty
                            ? "Username is available"
                            : hint_msg,
                        helperStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.teal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17)
                              .copyWith(topLeft: Radius.zero),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textPrimary.withAlpha(220),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(11)
                              .copyWith(topLeft: Radius.zero),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),

                    /// Email
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        final bool checkEmail = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value!);
                        if (value.isEmpty || value.length < 3) {
                          return "Enter Email";
                        }
                        if (!checkEmail) {
                          return "Enter Valid Email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        label: Text("Email"),
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17)
                              .copyWith(topLeft: Radius.zero),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textPrimary.withAlpha(220),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(11)
                              .copyWith(topLeft: Radius.zero),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    /// Password
                    TextFormField(
                      obscureText: pass,
                      controller: passController,
                      validator: (value) {
                        final bool passValid = RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                        ).hasMatch(value!);
                        if (value.isEmpty || value.length < 8) {
                          return "Invalid Password";
                        }
                        if (!passValid) {
                          return "Enter a Strong Password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password_outlined),
                        label: Text("Password"),
                        hintText: "Enter a strong password",
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              pass = !pass;
                            });
                          },
                          child: Icon(
                            pass
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17)
                              .copyWith(topLeft: Radius.zero),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textPrimary.withAlpha(220),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(11)
                              .copyWith(topLeft: Radius.zero),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Confirm Password
                    TextFormField(
                      obscureText: confpass,
                      controller: confPassController,
                      validator: (value) {
                        if (value != passController.text) {
                          return "Please re-check password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.key_outlined),
                        label: Text("Confirm Password"),
                        hintText: "Re-enter your password",
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              confpass = !confpass;
                            });
                          },
                          child: Icon(
                            confpass
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17)
                              .copyWith(topLeft: Radius.zero),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textPrimary.withAlpha(220),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(11)
                              .copyWith(topLeft: Radius.zero),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final isValid =
                              regFormKey.currentState?.validate() ?? false;
                          if (isValid) {
                            if (_usernameError.isEmpty) {
                              if (!context.mounted) return;
                              bool isCreated =
                              await signUpWithEmailAndPassword();
                              Fluttertoast.showToast(msg: excep.toString());
                              if (isCreated) {
                                model.userName = userNameController.text.trim();
                                model.email = emailController.text.trim();
                                model.pass = passController.text.trim();
                                model.uid = uid;
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) =>
                                        UserDetailsScreen(model: model,)),
                                    (route) => false);
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.textPrimary.withAlpha(220),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// Already have an account
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/signin',
                          ModalRoute.withName('/'),
                        );
                      },
                      child: const Text(
                        "Already have an account?",
                        style:
                        TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          : const Center(child: CircularProgressIndicator()),
    );
  }

}
