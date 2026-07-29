import 'package:chhaatra/materials/userData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../materials/app_colors.dart';

class DomainSelectionPage extends StatefulWidget {
  final UserData model;
  const DomainSelectionPage({super.key, required this.model});

  @override
  _DomainSelectionPageState createState() => _DomainSelectionPageState();
}

class _DomainSelectionPageState extends State<DomainSelectionPage> {
  List<String> selectedDomainsList = [];
  List<String> tech_Domains = [
    "Web Development",
    "Mobile App Development",
    "Machine Learning",
    "Artificial Intelligence",
    "Data Science",
    "Cybersecurity",
    "Cloud Computing",
    "DevOps",
    "Game Development",
    "Blockchain",
    "AR/VR Development",
    "Internet of Things (IoT)",
    "Embedded Systems",
    "Big Data",
    "UI/UX Design",
    "Computer Vision",
    "Natural Language Processing",
    "Database Administration",
    "Software Testing & QA",
    "Robotics",
  ];

  Future<bool> insertData() async{
    try {
      var isAdded = await FirebaseFirestore.instance.collection("users").doc(widget.model.userName).set (
          {
            'Username': widget.model.userName,
            'Email': widget.model.email,
            'Pass': widget.model.pass,
            'Profile': widget.model.profile ?? "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
            'Phone': widget.model.phone,
            'Bio': widget.model.bio,
            'Gender': widget.model.gender,
            'Languages': widget.model.languages,
            'Domains': widget.model.domains,
            'Solved': 0,
            'Replied': 0,
            'Posted': 0,
            'Posts': [],
            'Submissions':[],
            'XP': 0,
            'uid': widget.model.uid,
            'dob': widget.model.dob,
            'createdAt': Timestamp.now(),
          }
      );
      return true;
    }
    on FirebaseException catch(e) {
      print(e.message);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Center(child: Text("Interested Domains", style: TextStyle(color: Colors.white.withAlpha(220)))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tech_Domains.map((domain) {
                  final isSelected = selectedDomainsList.contains(domain);
                  return ChoiceChip(
                    label: Text(domain, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary.withAlpha(220),fontSize: 13)),
                    selected: isSelected,
                    selectedColor: AppColors.textPrimary.withAlpha(150),
                    onSelected: (val) {
                      setState(() {
                        isSelected ? selectedDomainsList.remove(domain) : selectedDomainsList.add(domain);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 40,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary.withAlpha(220),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  onPressed: () async {
                    // Save data logic here
                    if(selectedDomainsList.isNotEmpty){
                      widget.model.domains = selectedDomainsList;
                      print(widget.model.userName);
                      bool isAccCreated = await insertData();
                      if(isAccCreated){
                        Fluttertoast.showToast(
                            msg: "User Successfully Registered! Please Login ",
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppColors.bg2
                        );
                        Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
                      }else{
                        Fluttertoast.showToast(
                            msg: "Something Went Wrong, Please Try Again",
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppColors.bg2
                        );
                      }
                    }else{
                      Fluttertoast.showToast(
                          msg: "Please Select Atleast One Item",
                          timeInSecForIosWeb: 3,
                          backgroundColor: AppColors.bg2
                      );
                    }
        
                  },
                  child: Text("Finish", style: TextStyle(color: AppColors.bg, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
