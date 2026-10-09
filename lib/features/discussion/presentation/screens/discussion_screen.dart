import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscussionScreen extends ConsumerWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.precision_manufacturing,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              "This page is under Construction",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Compatibility alias
typedef Discussion = DiscussionScreen;
