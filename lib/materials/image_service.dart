import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:highlight/languages/http.dart';
import 'package:http/http.dart' as http;

class ImageService{
  static ImageService? service;
  Uint8List? imageBytes;

  Future<void> loadImage(fileName) async{
    final imgData = await getImage("$fileName.jpg");
    print("Hello");
    if(imgData!=null){
      imageBytes = imgData;
      print(imageBytes);
    }
    print("Hii");
  }

  Future<Map<String,dynamic>> uploadImage(File imageFile, String userName) async{
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
            })
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
      }
   catch (e) {
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
      }
      else {
        print("Failed to get Image");
        return null;
      }
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }
}