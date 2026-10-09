import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/userData.dart';
import 'domainSelection_screen.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  final UserData model;
  const LanguageSelectionPage({super.key, required this.model});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<LanguageSelectionPage> {
  List<String> selectedLangs = [];

  List<String> languages = [
    "C",
    "C++",
    "Java",
    "Python",
    "JavaScript",
    "TypeScript",
    "C#",
    "Go",
    "Rust",
    "PHP",
    "Swift",
    "Kotlin",
    "Dart",
    "Ruby",
    "SQL",
    "R",
    "MATLAB",
    "Scala",
    "Perl",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Center(
          child: Text(
            "Favourite Languages",
            style: TextStyle(color: Colors.white.withAlpha(220)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: languages.map((lang) {
                final isSelected = selectedLangs.contains(lang);
                return ChoiceChip(
                  label: Text(
                    lang,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary.withAlpha(220),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.textPrimary.withAlpha(150),
                  onSelected: (val) {
                    setState(() {
                      isSelected
                          ? selectedLangs.remove(lang)
                          : selectedLangs.add(lang);
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary.withAlpha(220),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                ),
                onPressed: () {
                  if (selectedLangs.isNotEmpty) {
                    widget.model.languages = selectedLangs;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DomainSelectionPage(model: widget.model),
                      ),
                      (route) => false,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please Select Atleast One Item",
                      timeInSecForIosWeb: 3,
                      backgroundColor: AppColors.bg2,
                    );
                  }
                },
                child: const Text(
                  "Next",
                  style: TextStyle(color: AppColors.bg, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
