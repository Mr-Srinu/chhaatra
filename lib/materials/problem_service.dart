import 'dart:convert';
import 'package:chhaatra/materials/problem.dart';
import 'package:http/http.dart' as http;

class ProblemService {
  final baseUrl = Uri.parse("https://cdn.jsdelivr.net/gh/bsv15/my_flutter_app@main/");
   late final folder;
   late final file;

   ProblemService({
    required this.folder,
    required this.file,
   });

  Future<List<Problem>> fetchProblems() async{
    final url = Uri.parse("$baseUrl$folder/$file.json?ts=${DateTime.now().millisecondsSinceEpoch}");
    final resp = await http.get(url);
    if(resp.statusCode==200){
      // final List<dynamic> jsonList = jsonDecode(resp.body);
      // List<Problem> problems = jsonList.map((json) => Problem.fromJson(json)).toList();
      // return problems;

      final List<dynamic> jsonList = jsonDecode(resp.body);
      List<Problem> problems = [];

      for (var json in jsonList) {
        try {
          problems.add(Problem.fromJson(json));
        } catch (e) {
          print("Error parsing a problem: $e");
          print("Offending data: $json");
        }
      }

      print("Successfully loaded ${problems.length} problems");
      return problems;
    }else{
      return [];
    }
  }
}