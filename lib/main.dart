import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showcaseview/showcaseview.dart';
import 'firebase_options.dart';
import 'app.dart';
export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    const ProviderScope(
      child: ShowCaseWidget(
        builder: _buildApp,
      ),
    ),
  );
}

Widget _buildApp(BuildContext context) => const MyApp();
