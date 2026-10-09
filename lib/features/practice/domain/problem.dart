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
      topic: json['topic'] as String? ?? '',
      level: json['level'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      constraints: json['constraints'] as String? ?? '',
      sampleInput: json['sampleInput'] as String? ?? '',
      sampleOutput: json['sampleOutput'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      starter: json['source'] as String? ?? '',
    );
  }

  // Backward compatibility factory
  factory Problem.fromMap(String id, Map<String, dynamic> data) {
    return Problem(
      topic: data['topic'] ?? '',
      level: data['difficulty'] ?? data['level'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      constraints: data['constraints'] ?? '',
      sampleInput: data['sampleInput'] ?? '',
      sampleOutput: data['sampleOutput'] ?? '',
      explanation: data['explanation'] ?? '',
      starter: data['boilerplate'] != null ? data['boilerplate'].toString() : '',
    );
  }

  String get difficulty => level;
  String get id => title;
  List<String> get examples => sampleInput.isNotEmpty ? ["Input: $sampleInput -> Output: $sampleOutput"] : [];
  Map<String, String> get boilerplate => {'c': starter, 'cpp': starter, 'python': starter, 'java': starter};
}
