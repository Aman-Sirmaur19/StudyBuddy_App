import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../main.dart';
import '../../../services/apis.dart';
import '../../../utils/dialogs.dart';
import '../../../widgets/custom_title.dart';
import '../../../widgets/particle_animation.dart';
import '../../home_screen.dart';

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            particles(context),
            Padding(
              padding: EdgeInsets.only(
                  left: mq.width * .1,
                  right: mq.width * .1,
                  top: mq.height * .15),
              child: SingleChildScrollView(
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
                              gradient: SweepGradient(
                                  colors: [
                                    Colors.lightBlue.withOpacity(.85),
                                    Colors.lightBlue.shade400,
                                    Colors.lightBlue.shade400,
                                  ],
                                  startAngle: -1 * pi / 6,
                                  endAngle: pi * 11 / 6),
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
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Enter the 6-digits verification code sent on your phone number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
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
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Colors.lightBlue))
                        : ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.lightBlue),
                            ),
                            child: const Text('Verify OTP'),
                            onPressed: () async {
                              if (otp.isEmpty) {
                                Dialogs.showErrorSnackBar(
                                    context, 'Please enter the OTP.');
                                return;
                              }

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
                                await APIs.auth
                                    .signInWithCredential(credential)
                                    .then((value) async {
                                  if (await APIs.userExists()) {
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => const HomeScreen()),
                                    );
                                  } else {
                                    await APIs.createUser().then((value) {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (_) => const HomeScreen()),
                                      );
                                    });
                                  }
                                });
                              } on FirebaseAuthException catch (e) {
                                Dialogs.showErrorSnackBar(context, e.message!);
                              } catch (e) {
                                Dialogs.showErrorSnackBar(
                                    context, e.toString());
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
