import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../main.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../widgets/particle_animation.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
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
          dev.log(error.message);
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
    String image = '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        centerTitle: true,
        title: const Text(
          'Custom Avatar',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: Stack(
        children: [
          particles(context),
          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: FluttermojiCircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(
                    width: min(600, mq.width * 0.85),
                    child: Row(
                      children: [
                        Text(
                          "Customize:",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        FluttermojiSaveWidget(onTap: () async {
                          image = await FluttermojiFunctions()
                              .encodeMySVGtoString();
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(APIs.user.uid)
                              .update({'image': image});
                          Dialogs.showSnackBar(context,
                              'Profile picture updated!\nKindly pull down in home-screen to\nrefresh.');
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 30),
                    child: FluttermojiCustomizer(
                      scaffoldWidth: min(600, mq.width * 0.85),
                      autosave: false,
                      theme: FluttermojiThemeData(
                          boxDecoration:
                              const BoxDecoration(boxShadow: [BoxShadow()])),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
