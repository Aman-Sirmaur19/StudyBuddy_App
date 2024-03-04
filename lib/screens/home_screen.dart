import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../main.dart';
import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import '../widgets/main_drawer.dart';

import './auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  FilePickerResult? _pickedFile;
  String? _name;
  bool _isPicked = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GlowIcon(
          CupertinoIcons.home,
          color:
              themeProvider.isDarkMode ? Colors.lightGreenAccent : Colors.green,
        ),
        title: const Text('PrepNight'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const GlowIcon(Icons.logout, color: Colors.redAccent),
            onPressed: showAlertDialog,
          )
        ],
      ),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload_file_outlined),
        onPressed: () async {
          final pickedFile = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            allowCompression: true,
          );
          if (pickedFile != null) {
            setState(() {
              _pickedFile = pickedFile;
              _name = pickedFile.files[0].name;
              _isPicked = true;
            });
          }
        },
      ),
      body: _isPicked
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset('assets/images/pdf.png',
                      width: mq.width * .5),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$_name',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        child: const Text('Yes'),
                        onPressed: () async {
                          APIs.pickFile(_pickedFile);
                          Dialogs.showUpdateSnackBar(
                              context, 'PDF Uploaded Successfully!');
                          setState(() {
                            _isPicked = false;
                            _pickedFile = null;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        child: const Text('No'),
                        onPressed: () {
                          setState(() {
                            _pickedFile = null;
                            _isPicked = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * .25),
                  child: Image.asset('assets/images/study.jpg',
                      width: mq.width * .7))),
    );
  }

  Future showAlertDialog() {
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
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => AuthScreen()));
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
