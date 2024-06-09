import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';

import '../widgets/particle_animation.dart';
import './auth/auth_screen.dart';
import './home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Reloading current user data each time when the app starts
      await FirebaseAuth.instance.currentUser?.reload();

      if (APIs.auth.currentUser != null) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Handle the case where the user is not found (probably deleted)
        // You can log the error or take appropriate action
        Dialogs.showErrorSnackBar(
            context, 'User not found. The user may have been deleted.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      } else {
        // Handle other FirebaseAuthExceptions if needed
        print('Error checking authentication: $e');
        Dialogs.showErrorSnackBar(context,
            'Something went wrong! (Check internet and restart the app)');
      }
    } catch (e) {
      // Handle generic errors
      print('Unexpected error checking authentication: $e');
    } finally {
      // Set loading to false regardless of the result
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          particles(context),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (isLoading) CircularProgressIndicator(),
                Image.asset('assets/images/study_buddy.png',
                    width: mq.width * .6),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        Colors.lightBlue.withOpacity(.85),
                        Colors.lightBlue.shade400,
                        Colors.lightBlue.shade400,
                      ],
                      startAngle: -1 * pi / 6,
                      endAngle: pi * 11 / 6,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Study',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            letterSpacing: 2,
                            color: Colors.yellowAccent.shade700,
                          )),
                      Text('Buddy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            letterSpacing: 2,
                            color: Colors.redAccent.shade400,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: mq.height * .06,
            width: mq.width,
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
                children: [
                  TextSpan(text: 'MADE WITH 💛 IN 🇮🇳'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
