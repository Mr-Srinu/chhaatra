import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/domain/usermodel.dart';

final gitServiceProvider = Provider<GitService>((ref) => GitService());

class GitService {
  late String loadedCode = '';

  Future<bool> uploadCodeToGist(
      String code, String extension, String topic, int problemNum) async {
    final user = UserModel.currentUser;
    if (user == null) {
      print("❌ User not logged in. Cannot upload.");
      return false;
    }

    final url =
        Uri.parse("https://bsv-git-code-uploader.myneedemail0001.workers.dev/");
    final subfolder = extension.startsWith('.') ? extension.substring(1) : extension;
    final filePath = '${topic}_${problemNum.toString()}';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": user.userName,
        "folder": "Submissions",
        "file": "$subfolder/$filePath.$subfolder",
        "content": code,
        "message": "Uploaded on ${DateTime.timestamp()}",
      }),
    );

    print(response.body);
    return response.statusCode == 200;
  }

  Future<bool> getCode(String extension, String topic, int problemNum) async {
    try {
      final user = UserModel.currentUser;
      if (user == null || user.userName.isEmpty) {
        print("❌ User not logged in. Cannot get code.");
        return false;
      }

      final subfolder = extension.startsWith('.') ? extension.substring(1) : extension;
      final filePath = '${topic}_${problemNum.toString()}';
      final url = Uri.parse(
          "https://bsv-git-code-uploader.myneedemail0001.workers.dev/?username=${user.userName}&folder=Submissions&file=$subfolder/$filePath.$subfolder");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        loadedCode = json['content'] ?? '';
        print("✅ Loaded code: $loadedCode");
        return true;
      } else {
        print("❌ Failed to get code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Exception: ${e.toString()}");
      return false;
    }
  }

  static Future<String> submitCode({
    required String code,
    required String language,
    required String problemId,
  }) async {
    const String baseUrl = "https://chhaatra-api.onrender.com";
    var response = await http.post(
      Uri.parse("$baseUrl/submit"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'language': language,
        'problemId': problemId,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['status'] ?? 'error';
    } else {
      throw Exception("Submission failed: ${response.statusCode}");
    }
  }
}
