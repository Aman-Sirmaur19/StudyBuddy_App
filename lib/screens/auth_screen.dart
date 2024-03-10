import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _isLoading = 0;
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              textAlign: TextAlign.center,
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Phone No.',
                prefixIcon: const Icon(Icons.phone_android_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            child: Text('Send OTP'),
            onPressed: () async {
              setState(() {
                _isLoading = 1;
              });
              await FirebaseAuth.instance.verifyPhoneNumber(
                verificationCompleted: (PhoneAuthCredential credential) {},
                verificationFailed: (FirebaseAuthException exception) {},
                codeSent: (String verificationId, int? resendToken) {
                  setState(() {
                    _isLoading = 2;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OTPScreen(verificationId: verificationId)));
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
                phoneNumber: '+91${phoneController.text}',
              );
            },
          ),
          const SizedBox(height: 10),
          _isLoading == 1
              ? const Text(
                  'Sending OTP...',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                )
              : _isLoading == 2
                  ? const Text(
                      'OTP sent',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    )
                  : const SizedBox(),
        ],
      ),
    );
  }
}
