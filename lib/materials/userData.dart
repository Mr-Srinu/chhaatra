import 'package:image_picker/image_picker.dart';

class UserData{
  UserData();
  String? uid;
  String? userName;
  String? email;
  String? pass;
  String? profile;
  String? phone;
  String? bio;
  String? gender;
  List<String> languages =[];
  List<String> domains=[];
  int solved=0;
  int replied=0;
  int posted=0;
  List<String> posts=[];
  List<String> submissions=[];
  int xp=0;
  String? dob;
  XFile? profileDummy;
  static UserData? currentData;
}