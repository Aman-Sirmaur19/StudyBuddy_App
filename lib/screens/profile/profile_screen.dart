import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../main.dart';
import '../../models/main_user.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../widgets/particle_animation.dart';

import '../profile/avatar_screen.dart';

// profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final MainUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isBannerLoaded = false;
  late BannerAd bannerAd;

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
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        bottomNavigationBar: isBannerLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
            : const SizedBox(),
        body: Stack(
          children: [
            particles(context),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(width: mq.width, height: mq.height * .03),
                      InkWell(
                        borderRadius: BorderRadius.circular(mq.height * .075),
                        onTap: () {
                          // _showBottomSheet();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AvatarScreen()));
                        },
                        child: FluttermojiCircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: mq.height * .075,
                        ),
                      ),
                      SizedBox(height: mq.height * .02),
                      Text(APIs.user.email!),
                      SizedBox(height: mq.height * .05),
                      customTextFormField(
                        widget.user.name,
                        (val) => APIs.me.name = val ?? '',
                        (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        CupertinoIcons.person,
                        'Name',
                        'eg. Aman Sirmaur',
                      ),
                      SizedBox(height: mq.height * .02),
                      customTextFormField(
                        widget.user.about,
                        (val) => APIs.me.about = val ?? '',
                        (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        CupertinoIcons.pencil_ellipsis_rectangle,
                        'About',
                        'eg. Feeling Happy!',
                      ),
                      SizedBox(height: mq.height * .02),
                      customTextFormField(
                        widget.user.branch,
                        (val) => APIs.me.branch = val ?? '',
                        (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        Icons.school_outlined,
                        'Branch',
                        'eg. Mechanical Engineering',
                      ),
                      SizedBox(height: mq.height * .02),
                      customTextFormField(
                        widget.user.college,
                        (val) => APIs.me.college = val ?? '',
                        (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        Icons.apartment_rounded,
                        'College',
                        'eg. NIT Agartala',
                      ),
                      SizedBox(height: mq.height * .02),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.lightBlue,
                          fixedSize: Size(mq.width * .35, mq.height * .05),
                        ),
                        icon: const Icon(Icons.edit_note_outlined),
                        label: const Text('Update'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackBar(
                                  context, 'Profile Updated Successfully!');
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTextFormField(
    String? initialValue,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
    IconData? icon,
    String? labelText,
    String? hintText,
  ) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
        ),
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
