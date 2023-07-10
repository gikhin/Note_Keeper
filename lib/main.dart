import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_keeper/Files/Loginpage.dart';
import 'package:note_keeper/Files/Updatetask.dart';
import 'package:note_keeper/Splashscreen.dart';

import 'Files/Signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Keeper',
      theme: ThemeData(

      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/Login': (context) => Login(),
        '/Signup': (context) => Signup(),
        '/Update': (context) => Update(),
      },
    );
  }
}


