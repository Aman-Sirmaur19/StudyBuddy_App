import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../providers/my_themes.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var otp = '';
  TextEditingController otpController = TextEditingController();

  // OtpFieldController otpController = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Screen'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 30,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Pinput(
              length: 6,
              onChanged: (value) {
                setState(() {
                  otp = value;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            child: Text('Verify OTP'),
            onPressed: () async {
              try {
                PhoneAuthCredential credential =
                    await PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: otp,
                );
                FirebaseAuth.instance
                    .signInWithCredential(credential)
                    .then((value) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                });
              } catch (exception) {
                log(exception.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
