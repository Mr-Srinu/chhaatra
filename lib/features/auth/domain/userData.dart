import 'package:image_picker/image_picker.dart';

class UserData {
  UserData();
  String? uid;
  String? userName;
  String? email;
  String? pass;
  String? profile;
  String? phone;
  String? bio;
  String? gender;
  List<String> languages = [];
  List<String> domains = [];
  int solved = 0;
  int replied = 0;
  int posted = 0;
  List<String> posts = [];
  List<String> submissions = [];
  int xp = 0;
  String? dob;
  XFile? profileDummy;
  static UserData? currentData;

  // Compatibility aliases
  static String? get name => currentData?.userName;
  static set name(String? val) {
    currentData ??= UserData();
    currentData!.userName = val;
  }

  static String? get mobile => currentData?.phone;
  static set mobile(String? val) {
    currentData ??= UserData();
    currentData!.phone = val;
  }

  static String? get domain => currentData?.domains.isNotEmpty == true ? currentData!.domains.first : null;
  static set domain(String? val) {
    currentData ??= UserData();
    if (val != null) {
      currentData!.domains = [val];
    }
  }

  static String? get language => currentData?.languages.isNotEmpty == true ? currentData!.languages.first : null;
  static set language(String? val) {
    currentData ??= UserData();
    if (val != null) {
      currentData!.languages = [val];
    }
  }

  static String? get profileImage => currentData?.profile;
  static set profileImage(String? val) {
    currentData ??= UserData();
    currentData!.profile = val;
  }

  static DateTime? get createdAt => null;

  static Future<void> fetchUserData() async {}
}
