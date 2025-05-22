import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_update/in_app_update.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import '../widgets/main_drawer.dart';
import '../widgets/custom_title.dart';
import '../widgets/custom_banner_ad.dart';
import '../widgets/custom_navigation.dart';
import '../widgets/particle_animation.dart';
import 'upload_pdf_screen.dart';
import 'college notes/home.dart';
import 'college notes/branches.dart';
import 'auth/email signin/login.dart';
import 'youtube/youtube_topics.dart';
import 'youtube/home_youtube_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    // APIs.getSelfInfo();
  }

  Future<void> _refresh() async {
    // await APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: customTitle(22, 1),
          centerTitle: false,
        ),
        drawer: const MainDrawer(),
        bottomNavigationBar: const CustomBannerAd(),
        body: Stack(
          children: [
            particles(context),
            const Body(),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          _update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void _update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
  }

  _uploadPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowCompression: true,
    );
    if (pickedFile != null) {
      CustomNavigation().navigateWithAd(
          context,
          UploadPdfScreen(
            userId: APIs.user.uid,
            name: pickedFile.files[0].name,
            path: pickedFile.files.first.path!,
          ));
    }
  }

  Future _showLogOutAlertDialog() {
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
            onPressed: () => CustomNavigation()
                .navigateWithAd(context, const AllBranchesScreen())),
        const BranchesGrid(),
        const SizedBox(height: 20),
        const CustomBannerAd(),
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
              onPressed: () => CustomNavigation()
                  .navigateWithAd(context, const AllYoutubeScreen()),
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
        const HomeYoutubeGrid(),
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
