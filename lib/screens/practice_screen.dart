import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/topic_subtopic.dart';
import 'package:chhaatra/screens/topic_screen.dart';
import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late NavigatorState navigator;

  @override
  void initState() {
    tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  final Color cardColor = const Color(0xD2081A35);

  var cTopics = TopicSubtopic.cTopics;
  var cppTopics = TopicSubtopic.cppTopics;
  var pyTopics = TopicSubtopic.pythonTopics;
  var javaTopics = TopicSubtopic.javaTopics;
  var htmTopics = TopicSubtopic.htmlTopics;
  var jsTopics = TopicSubtopic.jsTopics;

  var cSubTopics = TopicSubtopic.cSubTopics;
  var cppSubTopics = TopicSubtopic.cppSubTopics;
  var pySubTopics = TopicSubtopic.pythonSubTopics;
  var javaSubTopics = TopicSubtopic.javaSubTopics;
  var htmSubTopics = TopicSubtopic.htmlSubTopics;
  var jsSubTopics = TopicSubtopic.jsSubTopics;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0.4,
        title: TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: tabController,
          labelColor: AppColors.textPrimary,
          indicatorColor: AppColors.textPrimary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: "C"),
            Tab(text: "C++"),
            Tab(text: "Python"),
            Tab(text: "Java"),
            Tab(text: "HTML"),
            Tab(text: "Java Script"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildTopicList(cTopics, cSubTopics),
          _buildTopicList(cppTopics, cppSubTopics),
          _buildTopicList(pyTopics, pySubTopics),
          _buildTopicList(javaTopics, javaSubTopics),
          _buildTopicList(htmTopics, htmSubTopics),
          _buildTopicList(jsTopics, javaSubTopics),
        ],
      ),
    );
  }

  Widget _buildTopicList(List<String> topics, List<List<String>> subTopics) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return Card(
          color: AppColors.bg2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: (){
              print(tabController.index);
              var fileName;
              if(tabController.index==0){
                fileName = TopicSubtopic.cFileNames;
              }
              else if(tabController.index==1){
                fileName = TopicSubtopic.cppFileNames;
              }
              else if(tabController.index==2){
                fileName = TopicSubtopic.pyFileNames;
              }
              else if(tabController.index==3){
                fileName = TopicSubtopic.javaFileNames;
              }
              else{
                fileName = TopicSubtopic.cFileNames;
              }
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>TopicScreen(
                    topicTitle: topics[index],
                    topicDesc: subTopics[index].join(", "),
                    langIndex: tabController.index,
                    file: fileName[index],
                  ))
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(

                title: Text(
                  topics[index],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    subTopics[index].join(", "),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigator = Navigator.of(context); // ✅ SAFE here
  }

  @override
  void dispose() {
    tabController.dispose();
    // ❌ Do NOT use: Navigator.of(context).pop();
    // ✅ Use cached reference if needed
    // navigator.pop(); // Optional: only if you really need it
    super.dispose();
  }
}
