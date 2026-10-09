import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:chhaatra/core/constants/app_colors.dart';
import 'package:chhaatra/features/auth/domain/usermodel.dart';
import 'package:chhaatra/features/practice/domain/problem.dart';

void main() {
  group('Clean Architecture Unit & Smoke Tests', () {
    test('AppColors constants verification', () {
      expect(AppColors.primary, const Color(0xFF1E46C5));
      expect(AppColors.bg, const Color(0xFF0A1F33));
      expect(AppColors.textPrimary, const Color(0xFF17DCF4));
    });

    test('UserModel serialization and deserialization', () {
      final userMap = {
        'uid': 'test-uid-123',
        'Username': 'developer',
        'Email': 'dev@test.com',
        'Profile': 'https://example.com/pic.png',
        'Phone': '9876543210',
        'Bio': 'Clean architecture builder',
        'Gender': 'Male',
        'Languages': ['Dart', 'Flutter', 'Python'],
        'Domains': ['Mobile App Development'],
        'Solved': 15,
        'Replied': 4,
        'Posted': 2,
        'Posts': ['p1', 'p2'],
        'Submissions': ['s1'],
        'XP': 120,
        'dob': '01/01/2000',
      };

      final user = UserModel.fromMap(userMap);
      expect(user.uid, 'test-uid-123');
      expect(user.userName, 'developer');
      expect(user.email, 'dev@test.com');
      expect(user.solved, 15);
      expect(user.xp, 120);

      final toMap = user.toMap();
      expect(toMap['Username'], 'developer');
      expect(toMap['Email'], 'dev@test.com');
      expect(toMap['Solved'], 15);
    });

    test('Problem model deserialization from json', () {
      final problemJson = {
        'topic': 'basics',
        'level': 'Easy',
        'title': 'Hello World in C',
        'description': 'Write a program to print Hello World',
        'constraints': 'None',
        'sampleInput': '',
        'sampleOutput': 'Hello World',
        'explanation': 'Print simple text',
        'source': '#include <stdio.h>\nint main() { printf("Hello World"); return 0; }',
      };

      final problem = Problem.fromJson(problemJson);
      expect(problem.title, 'Hello World in C');
      expect(problem.level, 'Easy');
      expect(problem.sampleOutput, 'Hello World');
      expect(problem.starter, contains('printf'));
    });
  });
}
