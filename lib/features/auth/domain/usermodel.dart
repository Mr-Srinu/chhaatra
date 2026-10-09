import 'package:cloud_firestore/cloud_firestore.dart';
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
    required this.dob,
  });

  UserModel copyWith({
    String? uid,
    String? userName,
    String? email,
    String? profile,
    String? phone,
    String? bio,
    String? gender,
    List<String> continents = const [],
    List<String>? languages,
    List<String>? domains,
    int? solved,
    int? replied,
    int? posted,
    List<String>? posts,
    List<String>? submissions,
    int? xp,
    String? dob,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      languages: languages ?? this.languages,
      domains: domains ?? this.domains,
      solved: solved ?? this.solved,
      replied: replied ?? this.replied,
      posted: posted ?? this.posted,
      posts: posts ?? this.posts,
      submissions: submissions ?? this.submissions,
      xp: xp ?? this.xp,
      dob: dob ?? this.dob,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      userName: map['Username'] ?? map['userName'] ?? map['name'] ?? '',
      email: map['Email'] ?? map['email'] ?? '',
      profile: map['Profile'] ?? map['profile'] ?? map['profileImage'] ?? '',
      phone: map['Phone'] ?? map['phone'] ?? map['mobile'] ?? '',
      bio: map['Bio'] ?? map['bio'] ?? '',
      gender: map['Gender'] ?? map['gender'] ?? '',
      languages: List<String>.from(map['Languages'] ?? map['languages'] ?? []),
      domains: List<String>.from(map['Domains'] ?? map['domains'] ?? []),
      solved: map['Solved'] ?? map['solved'] ?? 0,
      replied: map['Replied'] ?? map['replied'] ?? 0,
      posted: map['Posted'] ?? map['posted'] ?? 0,
      posts: List<String>.from(map['Posts'] ?? map['posts'] ?? []),
      submissions: List<String>.from(map['Submissions'] ?? map['submissions'] ?? []),
      xp: map['XP'] ?? map['xp'] ?? 0,
      dob: map['dob']?.toString() ?? '',
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
      'Solved': solved,
      'Replied': replied,
      'Posted': posted,
      'Posts': posts,
      'Submissions': submissions,
      'XP': xp,
      'dob': dob,
    };
  }

  static Future<void> savePrefs(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    prefs.setString("email", email);
    prefs.setBool("isLoggedIn", true);
  }

  static Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username");
    final email = prefs.getString("email");
    final islogged = prefs.getBool("isLoggedIn");

    if (islogged == true && username != null && username.isNotEmpty && email != null && email.isNotEmpty) {
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
