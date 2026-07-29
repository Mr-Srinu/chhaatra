import 'dart:convert';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/git_service.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:http/http.dart' as http;
import 'package:highlight/highlight.dart';

import 'package:flutter_highlight/themes/tomorrow-night-bright.dart';
import 'package:flutter_highlight/themes/xcode.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/darcula.dart';
import 'package:flutter_highlight/themes/night-owl.dart';

import 'package:highlight/languages/python.dart' as py;
import 'package:highlight/languages/cpp.dart' as cpp;
import 'package:highlight/languages/java.dart' as java;

class EditorScreen extends StatefulWidget {
  late String title;
  late String desc;
  late String constraints;
  final String sampleInput;
  final String sampleOutput;
  late String difficulty;
  late String lang;
  late String version;
  late String explanation;
  late String starter;
  late String extension;
  late String topic;
  late int problem_num;

  EditorScreen( {
    super.key,
    required this.title,
    required this.desc,
    required this.constraints,
    required this.sampleInput,
    required this.sampleOutput,
    required this.difficulty,
    required this.lang,
    required this.version,
    required this.explanation,
    required this.starter,
    required this.extension,
    required this.topic,
    required this.problem_num,
  });

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late CodeController _controller;
  String output = '';
  bool isCorrect = false;
  bool isBoilerplate = true;
  late bool isSubmitted;
  bool isAlreadySubmitted = false;
  int points = 0;

  final Map<String, Mode> languageModes = {
    'python': py.python,
    'c': cpp.cpp,
    'cpp': cpp.cpp,
    'java': java.java,
  };

  final Map<String, Map<String, TextStyle>> themes = {
    'Default': tomorrowNightBrightTheme,
    'Dracula': darculaTheme,
    'Xcode': xcodeTheme,
    'Night Owl': nightOwlTheme,
    'vs2015' : vs2015Theme
  };
  String selectedTheme = 'Default';
  final gitService = GitService();

  @override
  void initState() {
    // TODO: implement initState
    _controller = CodeController(
      text: widget.starter,
      language: languageModes[widget.lang],
    );
    isAlreadySubmittedCode().then((isLoaded) {
        if(gitService.loadedCode.isNotEmpty) {
          _controller.text = gitService.loadedCode.toString();
          isAlreadySubmitted = true;
        }else{
          _controller.text = widget.starter;
          isAlreadySubmitted = false;
        }
    });
    super.initState();
  }

  Future<bool> isAlreadySubmittedCode() async{
    isAlreadySubmitted = await gitService.getCode(widget.extension, widget.topic, widget.problem_num);
    if(isAlreadySubmitted) {
      return true;
    }else{
      return false;
    }
  }

  void checkCode() async{
    if(output.trim() == widget.sampleOutput.trim()){
      isCorrect = true;
    }
    else{
      isCorrect = false;
    }
  }

  // Simulate code execution
  void executeCode() async {
    setState(() {
      output = 'Running...\n\n';
    });

    final response = await http.post(
      Uri.parse("https://bsv-compiler.myneedemail0001.workers.dev"),
      headers: { "Content-Type": "application/json" },
      body: jsonEncode({
        "language": widget.lang,
        "version": widget.version,
        "source": _controller.text, // The user's code
        "input": widget.sampleInput,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final run = result['run'];

      setState(() {
        if (run['stderr'] != null && run['stderr'].toString().trim().isNotEmpty) {
          output = 'Error:\n${run['stderr']}';
        } else {
          output = run['stdout'] ?? 'No output';
          checkCode();
        }
      });
    } else {
      setState(() {
        output = 'Request failed: ${response.statusCode}\n${response.body}';
      });
    }
  }

  Future<void> submitCode() async{
    isSubmitted = await gitService.uploadCodeToGist(_controller.text,widget.extension,widget.topic,widget.problem_num);
    if(isSubmitted){
      if(isAlreadySubmitted){
        Fluttertoast.showToast(
          msg: "New Version got Submitted Successfully",
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green[60],
          fontSize: 14,
        );
      }
      else{
        updateXP();
        Fluttertoast.showToast(
          msg: "Code Submitted Successfully! \n You got $points XP",
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green[60],
          fontSize: 14,
        );
      }
    }
    else{
        Fluttertoast.showToast(
          msg: "Some thing went Wrong, Please Try again!",
          textColor: Colors.white,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red[60],
          fontSize: 14,
        );
    }
  }

  void updateXP(){
    if(!isAlreadySubmitted){
      points = 0;
      final level = widget.difficulty;
      print("Getting XP");
      var xp = UserModel.currentUser?.xp;
      print("Got XP");
      switch(level){
        case "Easy":
          points = 2;
          UserModel.currentUser?.xp = points + xp!;
          break;
        case "Medium":
          points = 4;
          UserModel.currentUser?.xp = points + xp!;
          break;
        case "Hard":
          points = 6;
          UserModel.currentUser?.xp = points + xp!;
          break;
        case "Tricky":
          points = 8;
          UserModel.currentUser?.xp = points + xp!;
          break;
        case "Real World Problem":
          points = xp! + 10;
          UserModel.currentUser?.xp = points;
          break;
      }
      print("XP points: ${UserModel.currentUser?.xp}");
      print(" Solved: ${UserModel.currentUser?.solved}");
      UserModel.currentUser?.solved += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
      ),
      body:
      widget.lang=="html" || widget.lang=="javascript" ? ErrorCard()
      : SingleChildScrollView (  // Wrap entire body in SingleChildScrollView for scrolling
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              ProblemCard(),
              SizedBox(height: 20,),
              // Code Editor Area with Dark Theme using CodeField
              Text("Code Editor", style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.bg2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),

                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: CodeTheme(
                        data: CodeThemeData(styles: themes[selectedTheme]),
                        child: CodeField(
                        controller: _controller,
                        textStyle: TextStyle(color: Colors.white, fontFamily: 'FiraCode',fontWeight: FontWeight.w800,fontSize: 17,letterSpacing:1.2),
                        background: Colors.black87,
                        maxLines: null,
                        minLines: 20,
                        gutterStyle: GutterStyle(
                          textStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier',fontSize: 13,height: 1.53,fontWeight: FontWeight.w300),
                          width: 75
                        ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,8,15,8),
                            child: DropdownButton(
                              value: selectedTheme,
                              icon: const Icon(Icons.color_lens, color: Colors.white70,size: 21,),
                              dropdownColor: AppColors.bg,
                              style: const TextStyle(color: Colors.white,fontSize: 13),
                              underline: const SizedBox(),
                              onChanged: (value){
                                setState(() {
                                  selectedTheme = value!;
                                });
                              },
                              items: themes.keys.map((themeName) {
                                return DropdownMenuItem<String>(
                                  value: themeName,
                                  child: Text(themeName),
                                );
                              }).toList(),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,8,16,8),
                            child: Tooltip(
                              message: "Boilerplate",
                              waitDuration: Duration(milliseconds: 300),
                              child: InkWell(
                                  onTap: (){
                                    if(isBoilerplate){
                                      setState(() {
                                        _controller.text="";
                                        isBoilerplate=false;
                                      });
                                    }else{
                                      setState(() {
                                        _controller.text=widget.starter;
                                        isBoilerplate=true;
                                      });
                                    }
                                  },
                                  child: Icon(Icons.integration_instructions_outlined,size: 21,color: Colors.white70,)),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,8,10,8),
                            child: Tooltip(
                              message: "Run",
                              waitDuration: Duration(milliseconds: 300),
                              child: InkWell(
                                  onTap: executeCode,
                                  child: Icon(Icons.play_circle_rounded,size: 33,color: Colors.white70,)),
                            ),
                          ),
                        ],
                      ),
                    )
                ]
                ),
              ),
              SizedBox(height: 20),

              // Run Button
              ElevatedButton(
                onPressed: !isCorrect ? null : submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Submit code",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 17),),
              ),
              SizedBox(height: 20),

              // Output Section with Reduced Size and Scrollable
              if (output.isNotEmpty)  // Only show when output is not empty
                Container(
                  width: double.infinity,  // Full width of the screen
                  padding: EdgeInsets.all(8),  // Padding inside output container
                  decoration: BoxDecoration(
                    color: Colors.black87,  // Dark background color for output
                    borderRadius: BorderRadius.circular(12),  // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bg2,
                        blurRadius: 8,
                        offset: Offset(0, 4),  // Shadow effect
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(  // Ensure output text is scrollable
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Output: ",style: TextStyle(fontSize: 18,color: AppColors.textPrimary),),
                        SizedBox(height: 10,),
                        Text(
                          output,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,  // White text color for contrast
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ErrorCard(){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied,color: Colors.deepOrange,size: 80,),
            Text("Sorry for the Inconvenience, We are working on this",style: TextStyle(fontSize: 28,fontWeight: FontWeight.w400),),
            Text("We make sure as soon as possible, Until Explore new skills"),
          ],
        ),
      ),
    );
  }

  Widget ProblemCard() {
    return Card(
      color: AppColors.bg2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.title),
            const SizedBox(height: 20),

            const Text("Difficulty:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.difficulty),
            const SizedBox(height: 20),

            const Text("Description:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.desc,style: TextStyle(wordSpacing: 4),),
            const SizedBox(height: 20),

            const Text("Constraints:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.constraints),
            const SizedBox(height: 20),

            const Text("Sample Input:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.sampleInput),
            const SizedBox(height: 20),

            const Text("Sample Output:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
            Text(widget.sampleOutput),
            const SizedBox(height: 20),

            widget.explanation.isEmpty ? Text("")
                : const Text("Explanation :", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: AppColors.textPrimary)),
                  Text(widget.explanation,style: TextStyle(wordSpacing: 3)),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
