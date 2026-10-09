import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class ImageService {
  static ImageService? service;
  Uint8List? imageBytes;

  Future<void> loadImage(dynamic fileName) async {
    final imgData = await getImage("$fileName.jpg");
    if (imgData != null) {
      imageBytes = imgData;
    }
  }

  Future<Map<String, dynamic>> uploadImage(
      File imageFile, String userName) async {
    try {
      final apiUrl = Uri.parse(
          "https://bsv-profile-uploader.myneedemail0001.workers.dev/");

      final bytes = await imageFile.readAsBytes();
      final baseContent = base64Encode(bytes);
      final fileName = "$userName.jpg";
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "file": fileName,
          "content": baseContent,
          "message": "Updated Profile"
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "fileUrl": data["fileUrl"],
          "rawUrl": data["rawUrl"],
        };
      } else {
        return {
          "success": false,
          "error": data["error"] ?? "Upload failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  Future<Uint8List?> getImage(String fileName) async {
    try {
      final apiUrl = Uri.parse(
          "https://bsv-profile-uploader.myneedemail0001.workers.dev/?file=$fileName");
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final base64Content = data['content'] as String;
        final cleanedContent = base64Content.replaceAll("\n", "");
        return base64Decode(cleanedContent);
      } else {
        print("Failed to get Image");
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<String?> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (image == null) return null;

      const String uploadUrl = "https://chhaatra-api.onrender.com/upload";
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var data = jsonDecode(body);
        return data['url'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
