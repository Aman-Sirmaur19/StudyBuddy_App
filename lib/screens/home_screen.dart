import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_glow/flutter_glow.dart';

import '../main.dart';
import '../models/category.dart';
import '../screens/pdf_screen.dart';
import '../screens/upload_pdf_screen.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../widgets/category_item.dart';
import '../widgets/main_drawer.dart';
import '../widgets/particle_animation.dart';

import './auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Study',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 1,
                    color: Colors.yellowAccent.shade700,
                  )),
              Text('Buddy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 1,
                    color: Colors.redAccent.shade400,
                  )),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.add),
              tooltip: 'Upload',
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
                        name: pickedFile.files[0].name,
                        path: pickedFile.files.first.path!,
                      ),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.info),
              tooltip: 'Info',
              onPressed: showInfoAlertDialog,
            ),
            IconButton(
              icon: const GlowIcon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Logout',
              onPressed: showLogOutAlertDialog,
            )
          ],
        ),
        drawer: const MainDrawer(),
        body: loading
            ? Center(child: CircularProgressIndicator())
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
                  '\u2022 Long press on the buttons to know it\'s functionality.\n',
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
