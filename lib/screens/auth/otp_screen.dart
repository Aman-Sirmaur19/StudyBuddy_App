import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../providers/my_themes.dart';
import '../home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var otp = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                keyboardType: TextInputType.number,
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
              child: const Text('Verify OTP'),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                try {
                  PhoneAuthCredential credential =
                      await PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: otp,
                  );
                  APIs.auth
                      .signInWithCredential(credential)
                      .then((value) async {
                    if ((await APIs.userExists())) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => HomeScreen()));
                    } else {
                      await APIs.createUser().then((value) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => HomeScreen()));
                      });
                    }
                  });
                } catch (exception) {
                  log(exception.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
