import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/problem.dart';

final problemServiceProvider = Provider.family<ProblemService, ({String folder, String file})>(
  (ref, params) => ProblemService(folder: params.folder, file: params.file),
);

class ProblemService {
  final baseUrl =
      Uri.parse("https://cdn.jsdelivr.net/gh/bsv15/my_flutter_app@main/");
  late final dynamic folder;
  late final dynamic file;

  ProblemService({
    required this.folder,
    required this.file,
  });

  Future<List<Problem>> fetchProblems([String? topic, String? subtopic]) async {
    final url = Uri.parse(
        "$baseUrl$folder/$file.json?ts=${DateTime.now().millisecondsSinceEpoch}");
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
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
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching problems: $e");
      return [];
    }
  }
}
