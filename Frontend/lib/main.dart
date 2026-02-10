import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'chat_ai_screen.dart';
import 'calenderfinal.dart';
import 'timeline.dart';
import 'signuppage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 91, 232, 103)),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginpageWidget(),
      //  initialRoute: '/chat',
      routes: {
      '/timeline': (context) => TimelineScreen(
            pageController: PageController(initialPage: 0),
            selectedIndex: 0,
          ),
      '/chat': (context) => ChatAiScreen(pageController:PageController(initialPage: 1),selectedIndex: 1,),
      '/calendar': (context) => CalenderfinalWidget(
            pageController: PageController(initialPage: 2),
            selectedIndex: 2,
          ),
       '/signup': (context) => SignUpPageWidget(),
       '/login': (context) => LoginpageWidget(),
    },
    );
  }
}

