import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../helper/dialogs.dart';

import '../../providers/my_themes.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _validate = false;
  int _isLoading = 0;
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'IN',
    e164Key: '',
  );

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

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
                        child: Row(
                          children: [
                            Text('Study',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  letterSpacing: 2,
                                  color: Colors.yellowAccent.shade700,
                                )),
                            Text('Buddy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  letterSpacing: 2,
                                  color: Colors.redAccent.shade400,
                                )),
                          ],
                        ),
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
                    color:
                        themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
                Text(
                  'Enter your phone number. We\'ll send you a verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color:
                        themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
                SizedBox(height: mq.height * .05),
                TextFormField(
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1),
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.purple,
                  controller: phoneController,
                  onChanged: (value) {
                    setState(() {
                      // also, if we don't write anything inside setState, then also verify icon appears.
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Phone No.',
                    errorText: _validate ? 'Enter 10 or more digits' : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Container(
                      width: mq.width * .25,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            onSelect: (value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            },
                            countryListTheme: CountryListThemeData(
                                bottomSheetHeight: mq.height * .6),
                          );
                        },
                        child: Text(
                          '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                            width: mq.width * .1,
                            margin: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                            child: const Icon(Icons.done,
                                color: Colors.white, size: 18))
                        : null,
                  ),
                ),
                SizedBox(height: mq.height * .02),
                _isLoading == 0
                    ? ElevatedButton(
                        child: Text(
                          'Send OTP',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: sendOtp,
                      )
                    : _isLoading == 1
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
        ),
      ),
    );
  }

  void sendOtp() async {
    String phoneNumber = phoneController.text.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      if (phoneNumber.length > 9) _isLoading = 1;
      _validate = phoneNumber.length <= 9;
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
      phoneNumber: '+${selectedCountry.phoneCode}$phoneNumber',
    );
  }
}
