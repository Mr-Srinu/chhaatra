
import 'package:chhaatra/firebase_options.dart';
import 'package:chhaatra/materials/app_colors.dart';
import 'package:chhaatra/materials/userData.dart';
import 'package:chhaatra/materials/usermodel.dart';
import 'package:chhaatra/screens/addPost_screen.dart';
import 'package:chhaatra/screens/discussion_screen.dart';
import 'package:chhaatra/screens/editor_screen.dart';
import 'package:chhaatra/screens/home_screen.dart';
import 'package:chhaatra/screens/job_screen.dart';
import 'package:chhaatra/screens/languageSelection_screen.dart';
import 'package:chhaatra/screens/practice_screen.dart';
import 'package:chhaatra/screens/profile_screen.dart';
import 'package:chhaatra/screens/signin_screen.dart';
import 'package:chhaatra/screens/signup_screen.dart';
import 'package:chhaatra/screens/splash_screen.dart';
import 'package:chhaatra/screens/topic_screen.dart';
import 'package:chhaatra/screens/userDetails_screen.dart';
import 'package:chhaatra/screens/verifyPhone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  // await UserModel.loadPrefs();
  // await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(
    ShowCaseWidget(builder: (context)=>MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chhaatra',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.textPrimary,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00000000)),
      // ),

      debugShowCheckedModeBanner: false,
      routes: {
        '/home' : (context)=>MyHomePage(title: "Chhaatra"),
        '/splash': (context)=>SplashScreen(),
        '/homeScreen' : (context)=>HomeScreen(),
        // '/editor' : (context)=>EditorScreen(
        //     title: "Hello world",desc: "We can't provide a description",
        //     constraints: "",sampleInput: "",sampleOutput: "",difficulty: "Easy",lang: "c",version: "10.2.0",explanation: "",starter: "",),
        '/problem' : (context)=>PracticeScreen(),
        '/signup' : (context)=>SignupScreen(),
        '/signin' : (context)=>SigninScreen(),
        '/jobs' : (context)=>JobScreen(),
      },
      initialRoute: '/splash',
      // home: VerifyPhoneScreen(name: "abc", email: "xyz@gmaail.com", pass: "Xasdfa@123", uid: "abc1234"),
      // home: SignupScreen(),
      // home: UserDetailsScreen(model: UserData(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List listOfScreens = [HomeScreen(),JobScreen(),PracticeScreen()];
    // EditorScreen(title: "Hello world",desc: "We can't provide a description",constraints: "",testcase: "",difficulty: "Easy",),

  int selectedOption=0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // backgroundColor: AppColors.bg,
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        // title: const Text(
        //   'Chhaatra',
        //   style: TextStyle(
        //     fontSize: 22,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        title: Image.asset(
          'assets/images/logo3.png',
          width: 120,
        ),
        bottom: PreferredSize(preferredSize: Size.fromHeight(0.2),
            child: Container(
              color: Colors.grey.shade300, // or Color(0xFFEEEEEE)
              height: 0.08,
            )
        ),
        actions: [
          // InkWell(
          //   onTap: () async{
          //     await FirebaseAuth.instance.signOut;
          //     Navigator.pushNamedAndRemoveUntil(context, '/signin', ModalRoute.withName('/'));
          //   },
          //   child: Icon(Icons.logout),
          // ),
          // SizedBox(width: 15,),
          InkWell(
              onTap: (){
                final user = FirebaseAuth.instance.currentUser;
                if(user!=null){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                }else{
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SigninScreen()));
                }
              },
              child: Icon(Icons.person_2_outlined)),
          SizedBox(width: 10,)
        ],
      ),

      body:
        listOfScreens[selectedOption],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 0.09,
            color: Colors.grey.shade300,
            thickness: 0.15,
          ),
          BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedOption,
              backgroundColor: AppColors.bg,
              selectedItemColor: AppColors.textPrimary.withAlpha(200),
              // selectedItemColor: Colors.blue,
              unselectedItemColor: AppColors.textSecondary,
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              // showUnselectedLabels: false,
              onTap: (value){
                setState(() {
                  selectedOption=value;
                });
              },
              items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Home",
                tooltip: "Home"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.work_outline_rounded),
                label: "Jobs",
                tooltip: "Jobs"
            ),
            BottomNavigationBarItem(
                icon:Icon(Icons.data_object_sharp),
                label: "Practice",
                tooltip: "Practice"),
          ]),
        ],
      ),
    );
  }

}
