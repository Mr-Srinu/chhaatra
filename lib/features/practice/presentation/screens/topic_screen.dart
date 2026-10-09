import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/problem_service.dart';
import '../../domain/problem.dart';
import 'editor_screen.dart';

class TopicScreen extends ConsumerStatefulWidget {
  final String topicTitle;
  final String topicDesc;
  final int langIndex;
  final String file;

  const TopicScreen({
    super.key,
    required this.topicTitle,
    required this.topicDesc,
    required this.langIndex,
    required this.file,
  });

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  late Future<List<Problem>> future_problems;
  late final String folder;
  late final String file;

  void setFolder(int index) {
    switch (index) {
      case 0:
        folder = "cproblems";
        break;
      case 1:
        folder = "cpp_problems";
        break;
      case 2:
        folder = "py_problems";
        break;
      case 3:
        folder = "java_problems";
        break;
      default:
        folder = "cproblems";
    }
  }

  @override
  void initState() {
    super.initState();
    file = widget.file;
    setFolder(widget.langIndex);

    final ProblemService ps = ProblemService(file: file, folder: folder);
    future_problems = ps.fetchProblems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(widget.topicTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InfoCard(topicTitle: widget.topicTitle, topicDesc: widget.topicDesc),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Center(
                  child: Text(
                    "Problems",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Problem>>(
              future: future_problems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error loading problems: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No problems found for this topic.'),
                  );
                } else {
                  List<Problem> problems = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: problems.length,
                    itemBuilder: (context, index) {
                      Problem p = problems[index];
                      return ProblemCard(
                        title: p.title,
                        description: p.description,
                        constraints: p.constraints,
                        sampleInput: p.sampleInput,
                        sampleOutput: p.sampleOutput,
                        difficulty: p.level,
                        selectedLang: widget.langIndex,
                        explanation: p.explanation,
                        starter: p.starter,
                        topic: widget.file,
                        problem_num: index,
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String topicTitle;
  final String topicDesc;

  const InfoCard({
    super.key,
    required this.topicTitle,
    required this.topicDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: AppColors.bg2,
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Title:", topicTitle),
            const SizedBox(height: 15),
            _buildInfoRow("Description:", topicDesc),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: AppColors.textPrimary)),
        const SizedBox(height: 5),
        Text(content,
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 15)),
      ],
    );
  }
}

class ProblemCard extends StatelessWidget {
  final String title;
  final String description;
  final String constraints;
  final String sampleInput;
  final String sampleOutput;
  final String difficulty;
  final int selectedLang;
  final String explanation;
  final String starter;
  final String topic;
  final int problem_num;

  const ProblemCard({
    super.key,
    required this.title,
    required this.description,
    required this.constraints,
    required this.sampleInput,
    required this.sampleOutput,
    required this.difficulty,
    required this.selectedLang,
    required this.explanation,
    required this.starter,
    required this.topic,
    required this.problem_num,
  });

  final Map<String, Color> levelStyle = const {
    "Easy": Colors.greenAccent,
    "Medium": Colors.blueAccent,
    "Hard": Colors.redAccent,
    "Tricky": Colors.orangeAccent,
    "Real World Problem": Colors.tealAccent,
  };

  ({String language, String version, String extension}) getLangDetails(int index) {
    switch (index) {
      case 0:
        return (language: "c", version: "10.2.0", extension: ".c");
      case 1:
        return (language: "cpp", version: "17", extension: ".cpp");
      case 2:
        return (language: "python", version: "3.10.0", extension: ".py");
      case 3:
        return (language: "java", version: "11.0.5", extension: ".java");
      case 4:
        return (language: "html", version: "5.0", extension: ".html");
      case 5:
        return (language: "javascript", version: "18.0.0", extension: ".js");
      default:
        return (language: "c", version: "10.2.0", extension: ".c");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.bg2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white10,
        onTap: () {
          final langDetails = getLangDetails(selectedLang);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorScreen(
                title: title,
                desc: description,
                constraints: constraints,
                sampleInput: sampleInput,
                sampleOutput: sampleOutput,
                difficulty: difficulty,
                lang: langDetails.language,
                version: langDetails.version,
                explanation: explanation,
                starter: starter,
                extension: langDetails.extension,
                topic: topic,
                problem_num: problem_num,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              /// Left Section: Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(description,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(175),
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              /// Right Section: Difficulty + Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(difficulty,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: levelStyle[difficulty] ?? Colors.grey)),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white54, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
