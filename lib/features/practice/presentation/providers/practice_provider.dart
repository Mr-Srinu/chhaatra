import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/problem_service.dart';
import '../../domain/problem.dart';

final practiceProblemsProvider = FutureProvider.family<List<Problem>, ({String folder, String file})>(
  (ref, params) async {
    final service = ref.watch(problemServiceProvider(params));
    return await service.fetchProblems();
  },
);

class CompilerResult {
  final String stdout;
  final String stderr;
  final bool isSuccess;

  CompilerResult({
    required this.stdout,
    required this.stderr,
    required this.isSuccess,
  });
}

class CodeCompilerService {
  static const String compilerUrl =
      "https://bsv-compiler.myneedemail0001.workers.dev";

  Future<CompilerResult> executeCode({
    required String language,
    required String version,
    required String source,
    required String input,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(compilerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "language": language,
          "version": version,
          "source": source,
          "input": input,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final run = result['run'] ?? {};
        final stderr = run['stderr']?.toString().trim() ?? '';
        final stdout = run['stdout']?.toString() ?? '';
        return CompilerResult(
          stdout: stdout,
          stderr: stderr,
          isSuccess: stderr.isEmpty,
        );
      } else {
        return CompilerResult(
          stdout: '',
          stderr: 'Request failed: ${response.statusCode}\n${response.body}',
          isSuccess: false,
        );
      }
    } catch (e) {
      return CompilerResult(
        stdout: '',
        stderr: 'Error: $e',
        isSuccess: false,
      );
    }
  }
}

final codeCompilerServiceProvider =
    Provider<CodeCompilerService>((ref) => CodeCompilerService());
