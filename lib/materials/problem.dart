
class Problem {
  final String topic;
  final String level;
  final String title;
  final String description;
  final String constraints;
  final String sampleInput;
  final String sampleOutput;
  final String explanation;
  final String starter;

  Problem({
    required this.topic,
    required this.level,
    required this.title,
    required this.description,
    required this.constraints,
    required this.sampleInput,
    required this.sampleOutput,
    required this.explanation,
    required this.starter,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      topic: json['topic'] as String,
      level: json['level'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      constraints: json['constraints'] as String,
      sampleInput: json['sampleInput'] as String? ?? '',
      sampleOutput: json['sampleOutput'] as String,
      explanation: json['explanation'] as String,
      starter: json['source'] as String,
    );
  }
}