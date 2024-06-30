import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../main.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../widgets/custom_title.dart';
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
    checkForUpdate();
    _checkAuthentication();
  }

  Future<void> checkForUpdate() async {
    dev.log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          dev.log('Update available!');
          update();
        }
      });
    }).catchError((error) {
      dev.log(error.toString());
    });
  }

  void update() async {
    dev.log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      dev.log(error.toString());
    });
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
            'Something went wrong! (Check internet connection and \"TAP ANYWHERE\")');
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
          InkWell(
            onTap: _checkAuthentication,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    child: customTitle(30, 2),
                  ),
                ],
              ),
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
