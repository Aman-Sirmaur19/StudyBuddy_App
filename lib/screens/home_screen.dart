import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_glow/flutter_glow.dart';

import '../screens/pdf_screen.dart';
import '../screens/upload_pdf_screen.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../widgets/category_item.dart';
import '../widgets/main_drawer.dart';

import './auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  void selectCategory(BuildContext ctx, String category) {
    Navigator.of(ctx).push(
        MaterialPageRoute(builder: (ctx) => PdfScreen(category: category)));
  }

  Future<void> _refresh() async {
    await APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'StudyBuddy',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.add),
              onPressed: () async {
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
                        pickedFile: pickedFile,
                        name: pickedFile.files[0].name,
                        path: pickedFile.files[0].path!,
                      ),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: showInfoAlertDialog,
            ),
            IconButton(
              icon: const GlowIcon(Icons.logout, color: Colors.redAccent),
              onPressed: showLogOutAlertDialog,
            )
          ],
        ),
        drawer: const MainDrawer(),
        body: GridView(
          padding: const EdgeInsets.all(25),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: DUMMY_CATEGORIES
              .map((catData) => InkWell(
                    onTap: () => selectCategory(context, catData.title),
                    splashColor: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(15),
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
                      child: Text(
                        catData.title,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  showInfoAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text(
              '--> NOTE <--',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '\u2022 It is recommended to set your profile, if you haven\'t.'),
                Text('\u2022 You can upload PDFs by tapping on \'+\' button.'),
                Text(
                    '\u2022 It is recommended to upload PDFs of compressed size.'),
              ],
            ),
          );
        });
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
                  child: const Text('Yes'),
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
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        });
  }
}
