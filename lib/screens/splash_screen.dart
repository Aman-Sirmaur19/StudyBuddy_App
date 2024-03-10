import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/dialogs.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Reloading current user data each time when the app starts
      await FirebaseAuth.instance.currentUser?.reload();

      if (FirebaseAuth.instance.currentUser != null) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (isLoading) CircularProgressIndicator(),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.width * .25),
              child:
                  Image.asset('assets/images/study.jpg', width: mq.width * .7),
            ),
          ],
        ),
      ),
    );
  }
}
