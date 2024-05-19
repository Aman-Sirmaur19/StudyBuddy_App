import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:prep_night/helper/dialogs.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _validate = false;
  int _isLoading = 0;
  TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Phone No.',
                  errorText: _validate ? 'Enter 10 digits' : null,
                  prefixIcon: const Icon(CupertinoIcons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Send OTP'),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                setState(() {
                  if (_phoneController.text.length == 10) _isLoading = 1;
                  _validate = _phoneController.text.length != 10;
                });
                await FirebaseAuth.instance.verifyPhoneNumber(
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException exception) {
                    setState(() {
                      _isLoading = 0;
                    });
                    Dialogs.showErrorSnackBar(context, exception.message!);
                  },
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
                  phoneNumber: '+91${_phoneController.text}',
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
      ),
    );
  }
}
