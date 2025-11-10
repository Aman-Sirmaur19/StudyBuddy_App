import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import '../services/apis.dart';
import '../utils/dialogs.dart';
import '../widgets/custom_title.dart';
import '../widgets/particle_animation.dart';
import 'home_screen.dart';
import 'auth/email signin/login.dart';

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
    await Future.delayed(const Duration(seconds: 2))
        .then((value) => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const HomeScreen()),
            ));

    // try {
    //   // Reloading current user data each time when the app starts
    //   await FirebaseAuth.instance.currentUser?.reload();
    //
    //   if (APIs.auth.currentUser != null &&
    //       APIs.auth.currentUser!.emailVerified) {
    //     // Navigate to home screen
    //     Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(builder: (_) => const HomeScreen()),
    //     );
    //   } else {
    //     // Navigate to login screen
    //     Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(builder: (_) => const LoginScreen()),
    //     );
    //   }
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     // Handle the case where the user is not found (probably deleted)
    //     // You can log the error or take appropriate action
    //     Dialogs.showErrorSnackBar(
    //         context, 'User not found. The user may have been deleted.');
    //     Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(builder: (_) => const LoginScreen()),
    //     );
    //   } else {
    //     // Handle other FirebaseAuthExceptions if needed
    //     dev.log('Error checking authentication: $e');
    //     Dialogs.showErrorSnackBar(context,
    //         'Something went wrong! (Check internet connection and "TAP ANYWHERE")');
    //   }
    // } catch (e) {
    //   // Handle generic errors
    //   dev.log('Unexpected error checking authentication: $e');
    // } finally {
    //   // Set loading to false regardless of the result
    //   // setState(() {
    //   //   isLoading = false;
    //   // });
    // }
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/study_buddy.png',
                    width: mq.width * .6),
                const SizedBox(height: 200),
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
                  child: customTitle(30, 2),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3),
                    children: const [
                      TextSpan(text: 'MADE WITH ❤️ IN 🇮🇳'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
