import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../main.dart';
import '../../providers/my_themes.dart';
import '../home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isLoading = false;
  var otp = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .1, right: mq.width * .1, top: mq.height * .15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: mq.width * .05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(mq.width * .05),
                          child: Image.asset('assets/images/study.jpg',
                              width: mq.width * .2)),
                      const Text('PrepNight',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            letterSpacing: 2,
                          )),
                    ],
                  ),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(mq.width * .1),
                    child: Image.asset('assets/images/login.jpg',
                        width: mq.width * .65)),
                Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 25,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: mq.height * .05),
                Pinput(
                  length: 6,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade300))),
                  onCompleted: (value) {
                    setState(() {
                      otp = value;
                    });
                  },
                ),
                SizedBox(height: mq.height * .02),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        child: const Text('Verify OTP'),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          FocusScope.of(context).unfocus();
                          try {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: otp,
                            );
                            APIs.auth
                                .signInWithCredential(credential)
                                .then((value) async {
                              if ((await APIs.userExists())) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomeScreen()));
                              } else {
                                await APIs.createUser().then((value) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HomeScreen()));
                                });
                              }
                            });
                          } catch (exception) {
                            setState(() {
                              _isLoading = false;
                            });
                            log(exception.toString());
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
