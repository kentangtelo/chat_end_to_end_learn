import 'package:chat_end_to_end/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Future<void>
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //   apiKey: "AIzaSyCTZp2HEQqz-O_tTaPyw78r1OEc8TbRZ3Q",
  //   appId: "1:20335003276:web:7d88a0b5d3b57b045bdda9",
  //   messagingSenderId: "20335003276",
  //   projectId: "chat-app-63de6",
  // ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat End to End',
      theme: ThemeData(
        primaryColor: Colors.orange[900],
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
