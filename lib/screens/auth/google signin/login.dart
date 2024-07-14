import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../api/apis.dart';
import '../../../helper/dialogs.dart';
import '../../../main.dart';
import '../../../providers/my_themes.dart';
import '../../../widgets/custom_title.dart';
import '../../../widgets/particle_animation.dart';
import '../../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  _handleGoogleButtonClick() {
    setState(() {
      isLoading = true;
    });
    _signInWithGoogle().then((user) async {
      if (user != null) {
        dev.log('\nUser: ${user.user}');
        dev.log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (error) {
      dev.log('\n_signInWithGoogle: $error');
      Dialogs.showErrorSnackBar(
          context, 'Something went wrong! (Check internet)');
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Scaffold(
        body: Stack(
          children: [
            particles(context),
            Padding(
              padding: EdgeInsets.only(
                  left: mq.width * .1,
                  right: mq.width * .1,
                  top: mq.height * .15),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: mq.width * .05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/study_buddy.png',
                            width: mq.width * .2),
                        Container(
                          margin: const EdgeInsets.only(left: 3),
                          decoration: BoxDecoration(
                            gradient: SweepGradient(colors: [
                              Colors.lightBlue.withOpacity(.85),
                              Colors.lightBlue.shade400,
                              Colors.lightBlue.shade400,
                            ], startAngle: -1 * pi / 6, endAngle: pi * 11 / 6),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: customTitle(30, 2),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .1),
                      child: Image.asset('assets/images/login.jpg',
                          width: mq.width * .65)),
                  Text(
                    'Register Here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: themeProvider.isDarkMode
                          ? Colors.grey
                          : Colors.black54,
                    ),
                  ),
                  Text(
                    'SignIn with your email-id',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: themeProvider.isDarkMode
                          ? Colors.grey
                          : Colors.black54,
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.lightBlue)
                      : ElevatedButton.icon(
                          onPressed: () {
                            _handleGoogleButtonClick();
                          },
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: mq.height * .03,
                          ),
                          label: RichText(
                            text: const TextSpan(
                              // style: TextStyle(color: Colors.lightBlue),
                              children: [
                                TextSpan(text: 'SignIn with '),
                                TextSpan(
                                  text: 'Google',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.lightBlue.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
