import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (FirebaseAuth.instance.currentUser != null) {
          // navigate to home screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          // navigate to login screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AuthScreen()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // initializing mediaQuery for getting device screen size
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(mq.width * .25),
          child: Image.asset('assets/images/study.jpg', width: mq.width * .7),
        ),
      ),
    );
  }
}
