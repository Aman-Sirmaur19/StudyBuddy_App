import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../main.dart';
import '../models/category.dart';
import '../screens/pdf_screen.dart';
import '../screens/upload_pdf_screen.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../widgets/category_item.dart';
import '../widgets/main_drawer.dart';
import '../widgets/custom_title.dart';
import '../widgets/particle_animation.dart';

import './auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;

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
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      onRefresh: () => _refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: customTitle(22, 1),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            customIconButton(const Icon(CupertinoIcons.add), 'Upload',
                () async {
              final pickedFile = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
                allowCompression: true,
              );
              if (pickedFile != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadPdfScreen(
                      name: pickedFile.files[0].name,
                      path: pickedFile.files.first.path!,
                    ),
                  ),
                );
              }
            }),
            customIconButton(
                const Icon(CupertinoIcons.info), 'Info', showInfoAlertDialog),
            customIconButton(
                const Icon(Icons.logout), 'Logout', showLogOutAlertDialog)
          ],
        ),
        drawer: const MainDrawer(),
        bottomNavigationBar: isBannerLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
            : const SizedBox(),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  particles(context),
                  GridView(
                    padding: EdgeInsets.all(mq.width * .06),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: mq.width * .5,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: mq.width * .05,
                      mainAxisSpacing: mq.width * .05,
                    ),
                    children: DUMMY_CATEGORIES
                        .map((catData) => InkWell(
                              onTap: () => selectCategory(context, catData),
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: EdgeInsets.all(mq.width * .04),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      catData.color.withOpacity(0.7),
                                      catData.color,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Image.asset(
                                        catData.image,
                                        width: mq.width * .15,
                                      ),
                                    ),
                                    Text(
                                      catData.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
      ),
    );
  }

  void selectCategory(BuildContext ctx, Category category) {
    Navigator.of(ctx).push(
        MaterialPageRoute(builder: (ctx) => PdfScreen(category: category)));
  }

  Future<void> _refresh() async {
    await APIs.getSelfInfo();
  }

  showInfoAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text(
              '-- NOTE --',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\u2022 It is recommended to set your profile, if you haven\'t.\n',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\u2022 You can upload PDFs by tapping on \'+\' button.\n',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\u2022 It is recommended to upload PDFs of compressed size (<= 5MB).\n',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\u2022 Copyright section is \'clickable\', where you can visit my github and contribute to the project.\n',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        });
  }

  Widget customIconButton(Icon icon, String tip, void Function()? onPressed) {
    return IconButton(
      icon: icon,
      tooltip: tip,
      onPressed: onPressed,
    );
  }

  Future showLogOutAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Do you want to logout?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () async {
                    // for showing progress dialog
                    Dialogs.showProgressBar(context);

                    // sign out from app
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AuthScreen()));
                    });
                  },
                ),
                TextButton(
                    child: Text(
                      'No',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        });
  }
}
