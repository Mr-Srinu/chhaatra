import 'package:flutter/material.dart';

class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.precision_manufacturing,size: 100,),
              SizedBox(height: 20,),
              Text("This page is under Construction",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)
            ],
          )
      ),
    );
  }
}
