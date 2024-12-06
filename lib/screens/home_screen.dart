import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import 'auth/email signin/login.dart';
import 'college notes/branches.dart';
import 'college notes/home.dart';
import 'upload_pdf_screen.dart';
import 'youtube/home.dart';
import 'youtube/youtube_topics.dart';
import '../widgets/custom_title.dart';
import '../widgets/main_drawer.dart';
import '../widgets/particle_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    checkForUpdate();
    initializeBannerAd();
    // APIs.getSelfInfo();
  }

  Future<void> _refresh() async {
    // await APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      onRefresh: () => _refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: customTitle(22, 1),
          centerTitle: false,
        ),
        drawer: const MainDrawer(),
        bottomNavigationBar: isBannerLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
            : const SizedBox(),
        body: Stack(
          children: [
            particles(context),
            const Body(),
          ],
        ),
      ),
    );
  }

  Future<void> checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
  }

  Widget customIconButton(Icon icon, String tip, void Function()? onPressed) {
    return IconButton(
      icon: icon,
      tooltip: tip,
      onPressed: onPressed,
    );
  }

  uploadPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowCompression: true,
    );
    if (pickedFile != null) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => UploadPdfScreen(
            userId: APIs.user.uid,
            name: pickedFile.files[0].name,
            path: pickedFile.files.first.path!,
          ),
        ),
      );
    }
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
                    await FirebaseAuth.instance.signOut().then((value) async {
                      // for hiding progress dialog
                      Navigator.pop(context);

                      // for moving to home screen
                      Navigator.pop(context);

                      // for replacing home screen with login screen
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
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

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      children: [
        _customRow(
            title: 'College Notes',
            context: context,
            onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const AllBranchesScreen()))),
        const BranchesGrid(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  'You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Tube',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const AllYoutubeScreen()));
              },
              child: Text(
                "Show All",
                style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.isDarkMode
                        ? Colors.lightBlue
                        : Colors.blue),
              ),
            )
          ],
        ),
        const YoutubeGrid(),
      ],
    );
  }

  Widget _customRow({
    required String title,
    required BuildContext context,
    required void Function()? onPressed,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text("Show All",
              style: TextStyle(
                  fontSize: 13,
                  color: themeProvider.isDarkMode
                      ? Colors.lightBlue
                      : Colors.blue)),
        )
      ],
    );
  }
}
