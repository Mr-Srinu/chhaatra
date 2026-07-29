import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String uid;
  final String userName;
  final String email;
  final String profile;
  final String phone;
  final String bio;
  final String gender;
  final List<String> languages;
  final List<String> domains;
  int solved;
  int replied;
  int posted;
  List<String> posts;
  List<String> submissions;
  int xp;
  final String dob;
  static UserModel? currentUser;

  UserModel({
    required this.uid,
    required this.userName,
    required this.email,
    required this.profile,
    required this.phone,
    required this.bio,
    required this.gender,
    required this.languages,
    required this.domains,
    required this.solved,
    required this.replied,
    required this.posted,
    required this.posts,
    required this.submissions,
    required this.xp,
    required this.dob
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      userName: map['Username'] ?? '',
      email: map['Email'] ?? '',
      profile: map['Profile'] ?? '',
      phone: map['Phone'] ?? '',
      bio: map['Bio'] ?? '',
      gender: map['Gender'] ?? '',
      languages: List<String>.from(map['Languages'] ?? []),
      domains: List<String>.from(map['Domains'] ?? []),
      solved: map['Solved'] ?? 0,
      replied: map['Replied'] ?? 0,
      posted: map['Posted'] ?? 0,
      posts: List<String>.from(map['Posts'] ?? []),
      submissions: List<String>.from(map['Submissions'] ?? []),
      xp: map['XP'] ?? 0,
      dob: map['dob'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'Username': userName,
      'Email': email,
      'Profile': profile,
      'Phone': phone,
      'Bio': bio,
      'Gender': gender,
      'Languages': languages,
      'Domains': domains,
      'solved': solved,
      'Replied': replied,
      'Posted': posted,
      'Posts': posts,
      'Submissions': submissions,
      'XP': xp,
    };
  }

  static Future<void> savePrefs(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    prefs.setString("email", email);
    prefs.setBool("isLoggedIn", true);
  }

  static Future<void> loadPrefs() async{
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username");
    final email = prefs.getString("email");
    final islogged = prefs.getBool("isLoggedIn");

    if(islogged! && username!.isNotEmpty && email!.isNotEmpty){
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(username)
              .get();
          if (doc.exists) {
            currentUser = UserModel.fromMap(doc.data()!);
          }
    }
    print(username);
  }

  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUser = null;
  }
}
