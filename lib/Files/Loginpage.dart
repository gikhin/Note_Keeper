import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note_keeper/Files/HomePage.dart';

import 'Signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscureText = true;

  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeIn,
      ),
    );
    // Start the animation after the widget is built
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _animationController?.forward();
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Fluttertoast.showToast(msg: 'User Successfully Loggedin');
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage(cameras: [])),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: const Text('Failed to login. Please check your Email or Password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _animation!,
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 55.0,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 210,
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            image: AssetImage('asset/login.gif'),
                          ),
                        ),
                      ),
                    SizedBox(height: 10,),
                      Text(
                        "LOG IN PAGE",
                        style: TextStyle(
                          color: Color(0xFF496ACE),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 15.0,
                          right: 15.0,
                          left: 15.0,
                          top: 12.0,
                        ),
                        child: TextFormField(
                          controller: email,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Your Email";
                            } else if (!val.contains('@')) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Enter Your Email',
                            labelText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 15.0,
                          right: 15.0,
                          left: 15.0,
                          top: 12.0,
                        ),
                        child: TextFormField(
                          controller: password,
                          obscureText: _obscureText,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Password Cannot be Empty";
                            } else if (val.length < 6) {
                              return "Password must be 6 letters long";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Enter Your Password',
                            labelText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Container(
                          height: 45,
                          width: 330,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF496ACE),
                              ),
                              onPressed: () {
                                _login();
                                if (formKey.currentState!.validate()) {
                                  debugPrint("All Validation Passed");
                                }
                              },
                              child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
