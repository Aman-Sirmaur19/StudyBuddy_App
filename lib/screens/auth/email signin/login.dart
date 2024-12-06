import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../home_screen.dart';
import '../../../main.dart';
import '../../../helper/dialogs.dart';
import '../../../providers/my_themes.dart';
import '../../../widgets/custom_title.dart';
import '../../../widgets/particle_animation.dart';

enum AuthMode { signUp, logIn, reset }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  bool isLoading = false;
  bool obstructPassword = true;
  bool obstructConfirmPassword = true;
  AuthMode _authMode = AuthMode.logIn;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8331104249',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
          dev.log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8331104249',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
          dev.log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.logIn) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.logIn;
      });
    }
  }

  resetPassword() async {
    if (email.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text.trim())
          .then((value) => Dialogs.showSnackBar(
              context, 'Password reset link sent to your email!'));
    } on FirebaseAuthException catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  login() async {
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text, password: password.text);
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const HomeScreen()));
      } else {
        await FirebaseAuth.instance.signOut();
        Dialogs.showErrorSnackBar(context, 'Email not verified!');
      }
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('invalid-credential')) {
        errorMessage = 'Invalid login credentials.';
      }
      Dialogs.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  signup() async {
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields!');
      return;
    }
    if (password.text.trim() != confirmPassword.text.trim()) {
      Dialogs.showErrorSnackBar(context, 'Re-enter same password!');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) async {
        await FirebaseAuth.instance.currentUser
            ?.sendEmailVerification()
            .then((value) {
          setState(() {
            _authMode = AuthMode.logIn;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verification link sent to your email!',
                      style: TextStyle(letterSpacing: 1, color: Colors.white)),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              backgroundColor: Colors.black87,
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      });
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak (minimum 6 characters).';
      }
      Dialogs.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: isBannerLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
            : const SizedBox(),
        body: Stack(
          children: [
            particles(context),
            Padding(
              padding: EdgeInsets.only(
                  left: mq.width * .1,
                  right: mq.width * .1,
                  top: mq.height * .15),
              child: ListView(
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
                  Text(
                    _authMode == AuthMode.logIn
                        ? 'Login Here'
                        : _authMode == AuthMode.signUp
                            ? 'Register Here'
                            : 'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: themeProvider.isDarkMode
                          ? Colors.grey
                          : Colors.black54,
                    ),
                  ),
                  Text(
                    _authMode == AuthMode.logIn
                        ? 'Login with your email-id & password'
                        : _authMode == AuthMode.signUp
                            ? 'Create your account with email-id & password'
                            : 'Enter your registered email to get password reset link',
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
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.blue,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_authMode != AuthMode.reset)
                    TextFormField(
                      obscureText: obstructPassword,
                      controller: password,
                      cursorColor: Colors.blue,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obstructPassword = !obstructPassword;
                            });
                          },
                          icon: Icon(obstructPassword == false
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                        hintText: 'Password',
                        hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                  if (_authMode == AuthMode.logIn)
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _authMode = AuthMode.reset;
                          });
                        },
                        child: Text('Forgot Password?',
                            style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey
                                    : Colors.black54)),
                      ),
                    ),
                  if (_authMode == AuthMode.signUp) const SizedBox(height: 10),
                  if (_authMode == AuthMode.signUp)
                    TextFormField(
                      enabled: _authMode == AuthMode.signUp,
                      obscureText: obstructConfirmPassword,
                      controller: confirmPassword,
                      cursorColor: Colors.blue,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obstructConfirmPassword =
                                  !obstructConfirmPassword;
                            });
                          },
                          icon: Icon(obstructConfirmPassword == false
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                  if (_authMode == AuthMode.signUp) const SizedBox(height: 10),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.lightBlue))
                      : ElevatedButton(
                          onPressed: () => _authMode == AuthMode.logIn
                              ? login()
                              : _authMode == AuthMode.signUp
                                  ? signup()
                                  : resetPassword(),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 15,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(_authMode == AuthMode.logIn
                              ? 'Login'
                              : _authMode == AuthMode.signUp
                                  ? 'Sign Up'
                                  : 'Send Link'),
                        ),
                  const SizedBox(height: 25),
                  Text(
                    _authMode == AuthMode.logIn
                        ? 'Don\'t have an account?'
                        : _authMode == AuthMode.signUp
                            ? 'Already have an account?'
                            : 'Don\'t want to reset password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? Colors.grey
                            : Colors.black54),
                  ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '${_authMode == AuthMode.logIn ? 'SIGN-UP' : 'LOGIN'} INSTEAD',
                      style: const TextStyle(
                          color: Colors.lightBlue,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
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
