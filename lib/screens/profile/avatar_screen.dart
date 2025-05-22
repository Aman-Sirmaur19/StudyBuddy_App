import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/particle_animation.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

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
      bottomNavigationBar: const CustomBannerAd(),
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
